from typing import List, Literal, Optional
from datetime import datetime, timezone
from models.camel_model import CamelModel


class InterviewQuestion(CamelModel):
    number: int
    question: str
    description: str


class SummaryDetail(CamelModel):
    summary_head: str
    details: List[str]


class InterviewMetadata(CamelModel):
    title: str
    estimated_duration: int
    duration_unit: str
    questions: List[InterviewQuestion]


class InterviewProgress(CamelModel):
    current_question: str
    current_question_number: int
    total_questions: int
    started_at: datetime = datetime.now(timezone.utc)
    duration_seconds: int = 0


class InterviewSession(CamelModel):
    interview_id: str
    state: Literal["ongoing", "completed", "suspended"]
    metadata: InterviewMetadata
    progress: InterviewProgress
    summaries: List[SummaryDetail] = []

class UserDetails(CamelModel):
    name: Optional[str] = None

# ✅ Root document for MongoDB (or any doc store)
class User(CamelModel):
    user_id: str
    metadata: UserDetails
    interviews: List[InterviewSession] = []
