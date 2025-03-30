from pydantic import BaseModel

class InitRequest(BaseModel):
    clientId: str
    name: str

class TranscriptRequest(BaseModel):
    audio: str