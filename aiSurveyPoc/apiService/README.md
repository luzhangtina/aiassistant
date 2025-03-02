# API Service
It provides /ws websocket to accept message from app and send message to app

## websocket message format
### Endpoint
```
/ws
```

### Message from app
- Type **client_init**
```
{
    "type": "client_init",
    "client_id": {user_id},
    "name": (user_name)
}
```
- Type **client_audio_response**
```
{
    "type": "client_audio_response",
    "client_id": {user_id},
    "name": (user_name),
    "audio_data": {Base64-encoded_WAV_data}
}
```

### Message to app
- Type **server_audio_response** when it is not the last survey response from API service
```
{
    "type": "server_audio_response",
    "isFinal": false,
    "audioBase64": {audio_chunk_in_base64_mp3_format},
    "surveyProgress": {survey progress in percentage. e.g. "50%"},
    "surveyFinished": false
}
```
- Type **server_audio_response** when it is last audio chunk
```
{
    "type": "server_audio_response",
    "isFinal": true,
    "audioBase64": null,
    "surveyProgress": {survey progress in percentage. e.g. "100%"},
    "surveyFinished": true
}
```

### Dependencies
- Vosk model vosk-model-en-us-0.22
- Python > 3.9
  - fastapi
  - uvicorn
  - httpx
  - edge-tts
  - pydub
  - vosk


### Start AI service
1. Download Vosk model [vosk-model-en-us-0.22](https://alphacephei.com/vosk/models)
2. Update api.py code to load vosk model from the path downloaded to in step 1
```
# Load Vosk Speech Model
model = Model("path/to/vosk-model-en-us-0.22")
```
3. Run command **python -m venv venv** to create venv directory
4. Run command **source venv/bin/activate** on macOS/Linux to activate the virtual environment
   or run command **venv\Scripts\activate** on Windows to activate the virtual environment
5. Run command **pip install -r requirements.txt** to install the requirement packages
6. Run command **uvicorn api:app --host localhost --port 6001** to start the api service
   The service is running on "ws://localhost:6001"
7. To stop service, run command **CTRL+C**