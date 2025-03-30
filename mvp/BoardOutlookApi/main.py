from fastapi import FastAPI
from api.routes import router as api_router
from api.websocket import websocket_endpoint
from services.stt_service import load_vosk_model

app = FastAPI()

# Include routes and WebSocket
app.include_router(api_router)
app.add_api_websocket_route("/ws", websocket_endpoint)

# Load STT VOSK model
load_vosk_model()
