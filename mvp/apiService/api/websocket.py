# web_socket.py
from fastapi import WebSocket, WebSocketDisconnect
from data.questions import get_survey_data
from services.tts_service import get_audio_from_edge
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
                    "I believe the board plays a crucial role in shaping and overseeing our long-term strategy. They dedicate time during quarterly meetings specifically to strategic discussions, going beyond routine performance reviews. This ensures that we’re not just reacting to short-term results but actively planning for sustainable growth. The board consistently challenges management’s proposals by asking thought-provoking questions and encouraging alternative perspectives. For example, during our recent expansion planning, they pushed us to consider emerging market risks and diversify our approach, leading to a more resilient strategy. Additionally, they stay informed on external factors — from economic trends to industry disruptions — through regular briefings from experts. This proactive approach helps the organization stay ahead of potential risks and seize new opportunities. Overall, their involvement ensures our strategy remains forward-thinking, adaptable, and aligned with our mission.",
                    "The board takes a proactive approach to risk management, integrating risk considerations directly into strategic discussions rather than treating it as a separate compliance task. They regularly review a comprehensive risk dashboard that covers financial metrics, operational risks, and emerging challenges like cybersecurity, ESG factors, and regulatory changes. Each major strategic decision includes an assessment of potential risks and opportunities, ensuring the organization balances resilience with growth. Additionally, the board periodically invites external experts to provide insights on evolving geopolitical risks and technological threats, helping them stay ahead of potential disruptions. The organization’s risk appetite is clearly defined and revisited annually to ensure it remains aligned with long-term strategic goals, fostering a culture that supports innovation while maintaining robust safeguards.",
                    "To effectively assess whether the board has the right mix of skills, diversity of thought, and industry knowledge, the board should be composed of individuals with a broad range of expertise, experience, and backgrounds. The ideal board should encompass a blend of technical skills, strategic vision, and industry-specific knowledge that align with the organization’s goals and challenges. In terms of governance culture, board discussions must be open and constructive. Board members should feel empowered to voice differing opinions and challenge assumptions, ensuring that decision-making is robust and well-informed. The diversity of thought within the board is essential for generating innovative ideas and preventing groupthink. Furthermore, the effectiveness of succession planning and director onboarding is crucial for maintaining long-term board effectiveness. A well-thought-out succession plan helps ensure that the board has a continuous pipeline of talent with the necessary skills and experience. Onboarding programs should be comprehensive, helping new directors quickly get up to speed with the organization’s culture, strategy, and key issues. In conclusion, if the board is diverse in skills, experience, and perspective, and has effective processes in place for governance, succession, and onboarding, it will be well-equipped to meet the organization’s needs and make informed decisions.",
                    "The board’s role in monitoring and supporting the performance of the CEO is critical to ensuring strong leadership and the overall success of the organization. To assess the board's effectiveness, it is important to look at how well they oversee leadership, talent development, and CEO succession. A high-performing board ensures that the CEO is held accountable for the organization’s performance and strategic direction, while also providing the necessary support for the CEO to lead effectively. The board should provide both challenge and support to the executive team, striking a balance between pushing for high performance and offering the resources and encouragement needed for success. This can include offering constructive feedback, addressing any potential gaps in leadership, and guiding the CEO in making strategic decisions. Effective CEO performance assessment should be ongoing and comprehensive, including both short-term results and long-term leadership development. The board should have a structured approach to evaluating CEO performance, using clear metrics and regular reviews to ensure that the CEO is meeting organizational goals and expectations. In addition, CEO and executive succession planning should be a forward-looking, proactive process. The board should have a structured plan for leadership continuity, ensuring that there is a pipeline of qualified candidates to take on the CEO role and other key leadership positions when needed. A clear succession plan helps mitigate risks associated with leadership transitions and ensures the organization remains stable and focused on its long-term objectives. In summary, an effective board supports the CEO by providing the right level of challenge and support, regularly assessing CEO performance, and ensuring strong succession planning to maintain leadership continuity.",
                    "The effectiveness of the Chair in leading the board is pivotal to the overall performance of the board and its ability to govern effectively. The Chair plays a crucial role in facilitating board discussions, ensuring that meetings are structured, focused, and productive. By setting clear agendas, guiding conversations, and managing the flow of discussions, the Chair helps the board focus on key issues and drive meaningful outcomes that align with the organization's strategic goals. A good Chair ensures that all board members have an opportunity to contribute, fostering a culture of participation, challenge, and collaboration. This balance is essential for effective decision-making, as it encourages diverse perspectives while maintaining a respectful and productive atmosphere. The Chair should actively manage any conflicts or disagreements, ensuring that all voices are heard and that discussions lead to actionable decisions. In addition to facilitating board meetings, the Chair has a responsibility to proactively develop the board’s effectiveness over time. This includes gathering feedback from board members to identify areas for improvement and implementing measures to enhance board performance. The Chair should also be actively involved in succession planning, ensuring that the board remains dynamic and capable of adapting to changing needs, while also fostering strong relationships and engagement among directors. Ultimately, the Chair’s ability to guide the board effectively, balance participation and challenge, and drive continuous improvement ensures that the board functions at its highest potential, making informed and strategic decisions for the organization’s success."
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
