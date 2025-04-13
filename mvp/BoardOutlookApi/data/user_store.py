import json
import os
from pathlib import Path
from typing import Optional
from datetime import datetime
from models.user import (
    User,
    UserDetails,
    InterviewMetadata,
    InterviewSession,
    InterviewProgress,
)

class UserStore:
    def __init__(self, storage_dir: str = "userdata"):
        self.storage_dir = Path(storage_dir)
        self.storage_dir.mkdir(parents=True, exist_ok=True)

    def get_user_by_id(self, user_id: str) -> Optional[User]:
        user_file = self.storage_dir / f"{user_id}.json"
        if user_file.exists():
            with user_file.open("r") as f:
                user_data = json.load(f)
                return User(**user_data)  # Convert the loaded JSON into a User object
        return None

    def save_user(self, user: User) -> None:
        user_file = self.storage_dir / f"{user.user_id}.json"
        with open(user_file, "w", encoding="utf-8") as f:
            json.dump(user.model_dump(by_alias=True, mode="json"), f, ensure_ascii=False, indent=4)

    def load_interview_template(self, template_name: str = "interview_001") -> dict:
        """Loads the interview template from the server."""
        template_path = Path(f"templates/{template_name}.json")
        if template_path.exists():
            with open(template_path, "r", encoding="utf-8") as f:
                return json.load(f)
        return {}

    def create_or_update_user(self, user_id: str, interview_id: str) -> User:
        """Fetch or create a user, load interview template, and add it to the user's interview list."""
        user = self.get_user_by_id(user_id)

        if not user:
            user = User(user_id=user_id, metadata=UserDetails(), interviews=[])

        # Check if the interview already exists for the user
        existing_interview = next(
            (i for i in user.interviews if i.interview_id == interview_id), None
        )

        if not existing_interview:
            # Load interview template and create a new InterviewSession
            interview_data = self.load_interview_template()
            if interview_data:
                interview_metadata = InterviewMetadata(**interview_data)
                interview_session = InterviewSession(
                    interview_id=interview_id,
                    state="ongoing",
                    metadata=interview_metadata,
                    progress=InterviewProgress(
                        current_question=interview_metadata.questions[0].question,
                        current_question_number=interview_metadata.questions[0].number,
                        total_questions=len(interview_metadata.questions),
                    ),
                )
                user.interviews.append(interview_session)
                self.save_user(user)  # Save the updated user
        return user
    
# Instantiate the store globally
user_store = UserStore()
