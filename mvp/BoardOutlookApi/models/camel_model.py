from pydantic import BaseModel
from typing import Any

def to_camel(string: str) -> str:
    parts = string.split('_')
    return parts[0] + ''.join(word.capitalize() for word in parts[1:])

class CamelModel(BaseModel):
    model_config = {
        "populate_by_name": True,
        "alias_generator": to_camel
    }
