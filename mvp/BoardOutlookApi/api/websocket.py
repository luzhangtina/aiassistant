# web_socket.py
from fastapi import WebSocket, WebSocketDisconnect
from data.questions import get_survey_data
from services.tts_service import get_audio_from_edge
from services.stt_service import get_text_from_vosk
from data.client_context_store import client_context_store  # Import the global context store
from services.ai_service import compose_ai_messages, get_ai_response
from services.prompt_service import create_system_prompt
from data.magic_word import magic_word

async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()

    try:
        while True:
            data = await websocket.receive_json()
            client_id = data['clientId']
            name = data['name']
            user_audio_data_base64 = data['audioBase64']

            transcript = get_text_from_vosk(user_audio_data_base64)

            print(f"STT result is : {transcript}")

            try:
                user_context = client_context_store.get_context(client_id)
                context = user_context['context']
                number_of_question_in_progress = context['number_of_current_question']
                new_question = next(
                    (q['question'] for q in context['questions'] if q['number'] == number_of_question_in_progress),
                    "Question not found"
                )
                total_number = context['number_of_total_questions']
                progress = (number_of_question_in_progress * 100) // total_number

                history = user_context['history']
                chat_history = next((entry['chat_history'] for entry in history if entry.get('number_of_question') == number_of_question_in_progress), [])

                is_survey_completed = False

                user_responses = [
                    "I believe the board plays a crucial role in shaping and overseeing our long-term strategy. They dedicate time during quarterly meetings specifically to strategic discussions, going beyond routine performance reviews. This ensures that we’re not just reacting to short-term results but actively planning for sustainable growth. The board consistently challenges management’s proposals by asking thought-provoking questions and encouraging alternative perspectives. For example, during our recent expansion planning, they pushed us to consider emerging market risks and diversify our approach, leading to a more resilient strategy. Additionally, they stay informed on external factors — from economic trends to industry disruptions — through regular briefings from experts. This proactive approach helps the organization stay ahead of potential risks and seize new opportunities. Overall, their involvement ensures our strategy remains forward-thinking, adaptable, and aligned with our mission."
                ]
                
                # Prepare AI response
                ai_messages = compose_ai_messages(False, "", user_responses[number_of_question_in_progress-1], chat_history)
                ai_response = get_ai_response(ai_messages)

                user_answer_count = len([msg for msg in ai_messages if msg["role"] == "user"]) - 1

                print(f"user_answer_count {user_answer_count}")

                move_on_to_next = magic_word in ai_response or user_answer_count > 1

                print(f"move_on_to_next {move_on_to_next}")

                if ( move_on_to_next and number_of_question_in_progress < total_number):
                    if (magic_word in ai_response):
                        # Add ai response to current chat history
                        ai_response = ai_response.replace(magic_word, "").strip()
                        ai_messages.append({
                            "role": "assistant",
                            "content": ai_response
                        })
                    else:
                        ai_response = ""

                    # Move to next question
                    number_of_question_in_progress = number_of_question_in_progress + 1

                    new_question = next(
                        (q['question'] for q in context['questions'] if q['number'] == number_of_question_in_progress),
                        "Question not found"
                    )

                    survey_data = context['survey_data']
                    current_survey_data = get_survey_data(survey_data, 1)

                    # Generate system prompt for the AI
                    system_prompt = create_system_prompt(
                        init=False,
                        summary=False,
                        client_name=name,
                        question_text=new_question,
                        description=current_survey_data['description'],
                        chat_history=[],
                        magic_ending_word=magic_word
                    )

                    # Prepare AI response
                    ai_messages = compose_ai_messages(True, system_prompt, "", [])
                    new_ai_response = get_ai_response(ai_messages)

                    # Update client_context
                    ai_messages.append({
                        "role": "assistant",
                        "content": new_ai_response
                    })
                    history.append({
                        "number_of_question": number_of_question_in_progress,
                        "chat_history": ai_messages
                    })

                    # Update context
                    context['number_of_current_question'] = number_of_question_in_progress
                    context['current_question'] = new_question
                    context['progress'] = progress

                    ai_response = f"{ai_response} {new_ai_response}"

                elif (move_on_to_next and number_of_question_in_progress == total_number):
                    if (magic_word in ai_response):
                        # Add ai response to current chat history
                        ai_response = ai_response.replace(magic_word, "").strip()
                        ai_messages.append({
                            "role": "assistant",
                            "content": ai_response
                        })
                    else:
                        ai_response = ""

                    # Get summary of the survey
                    is_survey_completed = True

                    # Compose all question chat history
                    conversation = "\n".join(
                        f"{'Consultant' if message['role'] == 'assistant' else 'User'}: {message['content']}"
                        for entry in history
                        for message in entry.get('chat_history', [])
                        if message.get('role') in ['assistant', 'user']
                    )

                    # Generate system prompt for the AI
                    system_prompt = create_system_prompt(
                        init=False,
                        summary=True,
                        client_name=name,
                        question_text="",
                        description="",
                        chat_history=conversation,
                        magic_ending_word=""
                    )

                    # Prepare AI response
                    user_input = f"Please give me summary of the conversion. The conversion datails is: {conversation}"
                    ai_messages = compose_ai_messages(False, system_prompt, user_input, [])
                    new_ai_response = get_ai_response(ai_messages)

                    # Update client_context
                    user_context['survey_summary'] = new_ai_response

                    ai_response = f"{ai_response} {new_ai_response}"

                # Generate next audio
                audio_base64 = await get_audio_from_edge(ai_response)

                print(f"sending response to user")
                # Send response
                await websocket.send_json({
                    "currentNumberOfQuestion": number_of_question_in_progress,
                    "progress": progress,
                    "currentQuestion": new_question,
                    "audioBase64": audio_base64,
                    "isSurveyCompleted": is_survey_completed
                })

            except Exception as e:
                print("Error processing audio:", e)

    except WebSocketDisconnect:
        print(f"Client disconnected: {websocket.client}")
