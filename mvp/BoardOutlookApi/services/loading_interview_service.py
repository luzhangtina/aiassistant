from typing import Optional
from data.user_store import user_store
from models.loading_interview import LoadingInterviewResponse

def load_interview_for_user(user_id: str, interview_id: str) -> Optional[LoadingInterviewResponse]:
    user = user_store.create_or_update_user(user_id, interview_id)

    # Find the interview session from the user's interviews
    interview_session = next((i for i in user.interviews if i.interview_id == interview_id), None)
    
    if interview_session:
        metadata = interview_session.metadata

        # Return the interview details in the response format
        return LoadingInterviewResponse(
            title=metadata.title,
            estimated_duration=metadata.estimated_duration,
            duration_unit=metadata.duration_unit
        )
    return None
