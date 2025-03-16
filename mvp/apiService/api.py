import base64
import edge_tts

from fastapi import FastAPI, HTTPException, WebSocket, WebSocketDisconnect
from pydantic import BaseModel

# FastAPI App
app = FastAPI()

# In-memory storage for clients' context
client_context = {}

survey_questions = [
    {
        'number': 1,
        'question': "How effectively does the board shape and oversee the organization’s long-term strategy?",
        'objective': {
            'goal': "Assess the board’s role in guiding, challenging, and supporting strategy while ensuring long-term success.",
            'keypoints': [
                "Does the board allocate sufficient time to long-term strategic discussions rather than just reviewing management updates?",
                "How effectively does the board challenge and refine management’s strategic proposals?",
                "Does the board have a clear view of external trends, risks, and opportunities shaping strategy?"
            ]
        }
    },
    {
        'number': 2,
        'question': "How well does the board oversee and manage risk, balancing resilience with opportunity?",
        'objective': {
            'goal': "Evaluate how the board identifies, monitors, and mitigates risks, both financial and non-financial.",
            'keypoints': [
                "Is risk proactively embedded in board decision-making, or treated as a compliance exercise?",
                "Does the board ensure the organization is prepared for emerging risks, including cyber, ESG, regulatory, and geopolitical risks?",
                "How well does the board review and align the organization’s risk appetite with its strategic goals?"
            ]
        }
    },
    {
        'number': 3,
        'question': "Does the board have the right mix of skills, diversity of thought, and industry knowledge to meet the organization’s needs?",
        'objective': {
            'goal': "Assess whether the board’s membership, governance culture, and internal dynamics support strong decision-making.",
            'keypoints': [
                "Are board discussions open, constructive, and challenging where necessary?",
                "How effective is the board’s succession planning and director onboarding in maintaining long-term effectiveness?"
            ]
        }
    },
    {
        'number': 4,
        'question': "How well does the board monitor and support the performance of the CEO?",
        'objective': {
            'goal': "Evaluate the board’s effectiveness in overseeing leadership, talent development, and CEO succession.",
            'keypoints': [
                "Does the board provide the right level of challenge and support to the executive team?",
                "How effectively does the board assess and guide CEO performance and leadership development?",
                "Is there a structured, forward-looking approach to CEO and executive succession planning?"
            ]
        }
    },
    {
        'number': 5,
        'question': "How effectively does the Chair lead the board and get the best from all directors?",
        'objective': {
            'goal': "Assess the Chair’s role in facilitating effective board discussions, decision-making, and governance culture.",
            'keypoints': [
                "Does the Chair ensure board meetings are well-structured, focused, and drive meaningful outcomes?",
                "How effectively does the Chair balance participation, challenge, and collaboration among board members?",
                "Is the Chair proactively developing the board’s effectiveness through feedback, succession planning, and director engagement?"
            ]
        }
    }
]

questions_list = [
    {'number': item['number'], 'question': item['question']}
    for item in survey_questions
]

async def get_audio_from_edge(text_to_speak):
    print(f"text_to_speak: {text_to_speak}")

    communicate = edge_tts.Communicate(text_to_speak, voice='en-US-AvaMultilingualNeural')
    
    # Collect all audio chunks into a single byte buffer
    audio_data = bytearray()
    
    async for response in communicate.stream():
        if isinstance(response, dict) and "data" in response:
            audio_response = response["data"]
            audio_data.extend(audio_response)  # Accumulate chunks into a single byte array

    return bytes(audio_data)  # Convert bytearray to bytes and return

class InitRequest(BaseModel):
    clientId: str
    name: str

# API Endpoint: `/init`
@app.post("/api/init")
async def init_api(request: InitRequest):
    try:
        client_context[request.clientId] = {
            'history': [],
            'context': {
                'number_of_total_questions': len(questions_list),
                'number_of_current_question': 1,
                'progress': 0,
                'current_question': next(
                    (q['question'] for q in questions_list if q['number'] == 1),
                    "Question not found"
                ),
                'questions': questions_list
            }
        }

        user_context = client_context[request.clientId]['context']
        response_from_ai = f"Hi {request.name}. Hope you are doing well! let's start the survey! Question {user_context['number_of_current_question']}: {user_context['current_question']}"
        audio_data = await get_audio_from_edge(response_from_ai)
        audio_base64 = base64.b64encode(audio_data).decode('utf-8')
        response_data = {
            "numberOfTotalQuestions": user_context['number_of_total_questions'],
            "questions": user_context['questions'],
            "currentNumberOfQuestion": user_context['number_of_current_question'],
            "progress": user_context['progress'],
            "currentQuestion": user_context['current_question'],
            "audioBase64": audio_base64
        }
        return response_data
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    print(f"Client connecting: {websocket.client}")
    await websocket.accept()
    print(f"Client connected: {websocket.client}")
    count = 1
    try:
        while True:
            # Receive the audio stream from the client
            data = await websocket.receive_json()
            client_id = data['clientId'] 
            name = data['name']
            user_audio_data_base64 = data['audioBase64'] 
            
            print(f"client_id: {client_id}. name: {name}. user_audio_data_base64 (first 50 bytes): {user_audio_data_base64[:50]}")

            try:
                response_from_ai = "Thanks for your survey!"
                is_survey_completed = False
                new_question = ""

                user_context = client_context[client_id]['context']
                number_of_question_in_progress = user_context['number_of_current_question']
                total_number = user_context['number_of_total_questions']
                progress = (number_of_question_in_progress * 100) // total_number
                
                if (number_of_question_in_progress < total_number):
                    number_of_question_in_progress = number_of_question_in_progress + 1
                    new_question = next(
                        (q['question'] for q in questions_list if q['number'] == number_of_question_in_progress),
                        "Question not found"
                    )
                    
                    response_from_ai = new_question
                else:
                    is_survey_completed = True

                client_context[client_id]['context']['number_of_current_question'] = number_of_question_in_progress
                client_context[client_id]['context']['current_question'] = new_question
                client_context[client_id]['context']['progress'] = new_question


                audio_data = await get_audio_from_edge(response_from_ai)
                audio_base64 = base64.b64encode(audio_data).decode('utf-8')
                response_data = {
                    "currentNumberOfQuestion":number_of_question_in_progress,
                    "progress": progress,
                    "currentQuestion": new_question,
                    "audioBase64": audio_base64,
                    "isSurveyCompleted": is_survey_completed
                }
                await websocket.send_json(response_data)
            except Exception as e:
                print("Error processing audio:", e)
    except WebSocketDisconnect:
        print(f"Client disconnected: {websocket.client}")