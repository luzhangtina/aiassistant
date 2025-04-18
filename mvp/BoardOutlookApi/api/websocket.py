# web_socket.py
from fastapi import WebSocket, WebSocketDisconnect
from services.interview_service import process_user_answer

async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()

    try:
        while True:
            data = await websocket.receive_json()
            client_id = data['clientId']
            name = data['name']
            type = data['type']

            print(f'CurrentMessageTypeIs: {type}')
            if type == 'IsUserReady':
                print(f'IsUserReady')
            else:
                await process_user_answer(data, client_id, name, websocket)

    except WebSocketDisconnect:
        print(f"Client disconnected: {websocket.client}")