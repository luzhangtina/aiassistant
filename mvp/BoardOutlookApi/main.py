import os
from fastapi import FastAPI
from api.routes import router as api_router
from api.websocket import websocket_endpoint

app = FastAPI()

# Include routes and WebSocket
app.include_router(api_router)
app.add_api_websocket_route("/ws", websocket_endpoint)
