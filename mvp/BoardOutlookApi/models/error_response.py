from models.camel_model import CamelModel

class ErrorResponse(CamelModel):
    status: str
    message: str
    detail: str = None  # Optional additional details for debugging
