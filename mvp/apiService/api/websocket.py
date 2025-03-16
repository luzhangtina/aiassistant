# web_socket.py
from fastapi import WebSocket, WebSocketDisconnect
from services.tts_service import get_audio_from_edge
from data.client_context_store import client_context_store  # Import the global context store

async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()

    try:
        while True:
            data = await websocket.receive_json()
            client_id = data['clientId']
            name = data['name']
            user_audio_data_base64 = data['audioBase64']

            try:
                user_context = client_context_store.get_context(client_id)['context']
                number_of_question_in_progress = user_context['number_of_current_question']
                total_number = user_context['number_of_total_questions']
                progress = (number_of_question_in_progress * 100) // total_number

                # Move to the next question
                is_survey_completed = False
                if number_of_question_in_progress < total_number:
                    number_of_question_in_progress += 1
                    new_question = next(
                        (q['question'] for q in user_context['questions'] if q['number'] == number_of_question_in_progress),
                        "Question not found"
                    )
                else:
                    new_question = "Survey complete!"
                    is_survey_completed = True

                # Update context
                user_context['number_of_current_question'] = number_of_question_in_progress
                user_context['current_question'] = new_question
                user_context['progress'] = progress

                # Generate next audio
                audio_base64 = await get_audio_from_edge(new_question)

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
