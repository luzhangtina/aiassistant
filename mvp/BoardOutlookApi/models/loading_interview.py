from models.camel_model import CamelModel

class LoadingInterviewRequest(CamelModel):
    user_id: str
    interview_id: str

class LoadingInterviewResponse(CamelModel):
    title: str
    estimated_duration: int
    duration_unit: str