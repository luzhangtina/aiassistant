# routes.py
from fastapi import APIRouter, HTTPException
from models.request_models import InitRequest, TranscriptRequest
from services.tts_service import get_audio_from_edge
from data.questions import load_survey, get_question_list, get_survey_data
from data.client_context_store import client_context_store
from services.prompt_service import create_system_prompt
from services.ai_service import compose_ai_messages, get_ai_response
from data.magic_word import magic_word

router = APIRouter()

@router.post("/api/init")
async def init_api(request: InitRequest):
    try:
        # Load survey data (default or custom)
        survey_data = load_survey()
        questions_list = get_question_list(survey_data)
        current_survey_data = get_survey_data(survey_data, 1)

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
                'questions': questions_list,
                'survey_data': survey_data
            }
        })

        # Generate the system prompt
        user_context = client_context_store.get_context(request.clientId)
        question_text = current_survey_data['question']
        description = current_survey_data['description']
        
        # Generate system prompt for the AI
        system_prompt = create_system_prompt(
            init=True,
            summary=False,
            client_name=request.name,
            question_text=question_text,
            description=description,
            chat_history=[],
            magic_ending_word=magic_word
        )

        # Prepare AI response
        ai_messages = compose_ai_messages(True, system_prompt, "", [])
        ai_response = get_ai_response(ai_messages)

        # Get audio of AI response
        audio_base64 = await get_audio_from_edge(ai_response)

        # Update client_context
        ai_messages.append({
            "role": "assistant",
            "content": ai_response
        })
        user_context['history'].append({
            "number_of_question": 1,
            "chat_history": ai_messages
        })

        client_context_store.set_context(request.clientId, user_context)

        context = user_context['context']
        # Return response
        return {
            "numberOfTotalQuestions": context['number_of_total_questions'],
            "questions": context['questions'],
            "currentNumberOfQuestion": context['number_of_current_question'],
            "progress": context['progress'],
            "currentQuestion": context['current_question'],
            "audioBase64": audio_base64
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
