from fastapi import WebSocket
from typing import Dict
from services.shared import recognizer_manager
from data.client_context_store import client_context_store
from data.questions import get_survey_data
from data.magic_word import magic_word
from services.ai_service import (
    compose_ai_messages,
    get_ai_response,
)
from services.prompt_service import create_system_prompt
from services.tts_service import get_audio_from_edge


async def process_user_answer(data: Dict, client_id: str, name: str, websocket: WebSocket):
    user_audio_data_base64 = data.get('audioBase64')
    
    if user_audio_data_base64:
        try:
            if data.get("isFirstChunk", True):
                print(f"Received first chunk from {client_id}, resetting recognizer")
                recognizer_manager.reset_recognizer(client_id)
            recognizer_manager.process_audio(user_audio_data_base64, client_id)
        except Exception as e:
            print(f"Error processing audio: {e}")

    if data.get('isLastChunk', True):
        try:
            final_transcript = recognizer_manager.get_complete_transcript(client_id)
            print(f"final_transcript: {final_transcript}")

            user_context = client_context_store.get_context(client_id)
            context = user_context['context']
            number_of_question_in_progress = context['number_of_current_question']
            total_number = context['number_of_total_questions']
            progress = (number_of_question_in_progress * 100) // total_number

            history = user_context['history']
            chat_history = next((entry['chat_history'] for entry in history if entry.get('number_of_question') == number_of_question_in_progress), [])

            is_survey_completed = False

            ai_messages = compose_ai_messages(False, "", final_transcript, chat_history)
            ai_response = get_ai_response(ai_messages)
            user_answer_count = len([msg for msg in ai_messages if msg["role"] == "user"]) - 1

            move_on_to_next = magic_word in ai_response or user_answer_count > 1

            if move_on_to_next and number_of_question_in_progress < total_number:
                if magic_word in ai_response:
                    ai_response = ai_response.replace(magic_word, "").strip()
                    ai_messages.append({"role": "assistant", "content": ai_response})
                else:
                    ai_response = ""

                number_of_question_in_progress += 1
                new_question = next(
                    (q['question'] for q in context['questions'] if q['number'] == number_of_question_in_progress),
                    "Question not found"
                )
                current_survey_data = get_survey_data(context['survey_data'], 1)

                system_prompt = create_system_prompt(
                    init=False, summary=False, client_name=name,
                    question_text=new_question, description=current_survey_data['description'],
                    chat_history=[], magic_ending_word=magic_word
                )

                ai_messages = compose_ai_messages(True, system_prompt, "", [])
                new_ai_response = get_ai_response(ai_messages)
                ai_messages.append({"role": "assistant", "content": new_ai_response})

                history.append({
                    "number_of_question": number_of_question_in_progress,
                    "chat_history": ai_messages
                })

                context['number_of_current_question'] = number_of_question_in_progress
                context['current_question'] = new_question
                context['progress'] = progress

                ai_response = f"{ai_response} {new_ai_response}"

            elif move_on_to_next and number_of_question_in_progress == total_number:
                if magic_word in ai_response:
                    ai_response = ai_response.replace(magic_word, "").strip()
                    ai_messages.append({"role": "assistant", "content": ai_response})
                else:
                    ai_response = ""

                is_survey_completed = True

                conversation = "\n".join(
                    f"{'Consultant' if message['role'] == 'assistant' else 'User'}: {message['content']}"
                    for entry in history
                    for message in entry.get('chat_history', [])
                    if message.get('role') in ['assistant', 'user']
                )

                system_prompt = create_system_prompt(
                    init=False, summary=True, client_name=name,
                    question_text="", description="",
                    chat_history=conversation,
                    magic_ending_word=""
                )

                user_input = f"Please give me summary of the conversion. The conversion datails is: {conversation}"
                ai_messages = compose_ai_messages(False, system_prompt, user_input, [])
                new_ai_response = get_ai_response(ai_messages)

                user_context['survey_summary'] = new_ai_response
                ai_response = f"{ai_response} {new_ai_response}"

            new_question = context['current_question']
            audio_base64 = await get_audio_from_edge(ai_response)

            await websocket.send_json({
                "currentNumberOfQuestion": number_of_question_in_progress,
                "progress": progress,
                "currentQuestion": new_question,
                "audioBase64": audio_base64,
                "isSurveyCompleted": is_survey_completed
            })

        except Exception as e:
            print("Error processing audio:", e)
