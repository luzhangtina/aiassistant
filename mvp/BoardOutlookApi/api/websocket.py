# web_socket.py
from fastapi import WebSocket, WebSocketDisconnect
from services.interview_service import process_user_answer, is_user_ready
from models.web_socket_message import WebSocketMessage, WebSocketMessageType

async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()

    try:
        while True:
            data = await websocket.receive_json()
            message = WebSocketMessage(**data)
            message_type = message.message_type
            if message_type == WebSocketMessageType.IS_USER_READY_REQUEST:
                await is_user_ready(data, message.data, websocket)
            else:
                await process_user_answer(data, message.data, websocket)

    except WebSocketDisconnect:
        print(f"Client disconnected: {websocket.client}")