import base64
import edge_tts

from fastapi import FastAPI, HTTPException, WebSocket, WebSocketDisconnect
from pydantic import BaseModel

# FastAPI App
app = FastAPI()

# In-memory storage for clients' context
client_context = {}

async def get_audio_from_edge(sentence_pair):
    text_to_speak = " ".join(sentence_pair)
    
    print(f"text_to_speak: {text_to_speak}")

    communicate = edge_tts.Communicate(text_to_speak, voice='en-US-AvaMultilingualNeural')
    
    # Collect all audio chunks into a single byte buffer
    audio_data = bytearray()
    
    async for response in communicate.stream():
        if isinstance(response, dict) and "data" in response:
            audio_response = response["data"]
            audio_data.extend(audio_response)  # Accumulate chunks into a single byte array

    return bytes(audio_data)  # Convert bytearray to bytes and return

class InitRequest(BaseModel):
    clientId: str
    name: str

# API Endpoint: `/init`
@app.post("/api/init")
async def init_api(request: InitRequest):
    try:
        client_context[request.clientId] = {'history': []}
        response_from_ai = [
            f"Hi {request.name}.",
            f"Hope you are doing well! let's start the survey!"
        ]
        audio_data = await get_audio_from_edge(response_from_ai)
        audio_base64 = base64.b64encode(audio_data).decode('utf-8')
        response_data = {
            "transcript": f"Hello {request.name}, welcome!",
            "audioBase64": audio_base64
        }
        return response_data
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

count = 1

@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()

    try:
        while True:
            # Receive the audio stream from the client
            data = await websocket.receive_json()
            client_id = data['clientId'] 
            name = data['name']
            user_audio_data_base64 = data['audioBase64'] 
            
            print(f"client_id: {client_id}. name: {name}. user_audio_data_base64 (first 50 bytes): {user_audio_data_base64[:50]}")

            try:
                response_from_ai = [
                    f"This is follow up response.",
                    f"The number is {count}!"
                ]
                transcript = f"this is response {count}"
                count = count + 1

                audio_data = await get_audio_from_edge(response_from_ai)
                audio_base64 = base64.b64encode(audio_data).decode('utf-8')
                await websocket.send_json({"transcript": transcript, "audioBase64": audio_base64, "isSurveyCompleted": False})
            except Exception as e:
                print("Error processing audio:", e)
    except WebSocketDisconnect:
        print(f"Client disconnected: {websocket.client}")