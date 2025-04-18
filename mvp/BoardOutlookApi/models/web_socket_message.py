from models.camel_model import CamelModel
from typing import Union, Optional
from enum import Enum
from pydantic import root_validator

class WebSocketMessageType(str, Enum):
    IS_USER_READY_REQUEST = "IsUserReadyRequest"
    IS_USER_READY_RESPONSE = "IsUserReadyResponse"
    USER_INTERVIEW_ANSWER = "UserInterviewAnswer"

class UserInterviewAnswer(CamelModel):
    user_id: str
    interview_id: Optional[str] = None
    audio_base64: Optional[str] = None
    is_first_audio_chunk: bool = True
    is_last_audio_chunk: bool = True

class IsUserReadyResponse(CamelModel):
    user_id: str
    is_user_ready: bool
    transcript: str

class WebSocketMessage(CamelModel):
    message_type: WebSocketMessageType
    data: Union[UserInterviewAnswer, IsUserReadyResponse]

    @root_validator(pre=True)
    def parse_data(cls, values):
        msg_type = values.get("messageType")  # camelCase from incoming message
        data = values.get("data")

        if not isinstance(data, dict):
            return values

        if msg_type == WebSocketMessageType.IS_USER_READY_RESPONSE:
            values["data"] = IsUserReadyResponse(**data)
        elif msg_type in {
            WebSocketMessageType.IS_USER_READY_REQUEST,
            WebSocketMessageType.USER_INTERVIEW_ANSWER,
        }:
            values["data"] = UserInterviewAnswer(**data)
        else:
            raise ValueError(f"Unknown message_type: {msg_type}")

        return values
