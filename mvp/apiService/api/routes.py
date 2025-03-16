# routes.py
from fastapi import APIRouter, HTTPException
from models.request_models import InitRequest
from services.tts_service import get_audio_from_edge
from data.questions import load_survey, get_question_list
from data.client_context_store import client_context_store  # Import the global context store

router = APIRouter()

@router.post("/api/init")
async def init_api(request: InitRequest):
    try:
        # Load survey data (default or custom)
        survey_data = load_survey()
        questions_list = get_question_list(survey_data)

        # Initialize client context
        client_context_store.set_context(request.clientId, {
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
        })

        # Prepare AI response
        user_context = client_context_store.get_context(request.clientId)['context']
        response_from_ai = f"Hi {request.name}. Let's start the survey! Question {user_context['number_of_current_question']}: {user_context['current_question']}"
        audio_base64 = await get_audio_from_edge(response_from_ai)

        # Return response
        return {
            "numberOfTotalQuestions": user_context['number_of_total_questions'],
            "questions": user_context['questions'],
            "currentNumberOfQuestion": user_context['number_of_current_question'],
            "progress": user_context['progress'],
            "currentQuestion": user_context['current_question'],
            "audioBase64": audio_base64
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
