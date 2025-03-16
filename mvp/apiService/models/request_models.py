from pydantic import BaseModel

class InitRequest(BaseModel):
    clientId: str
    name: str
