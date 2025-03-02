import base64
import json
from io import BytesIO

import edge_tts
import httpx
import wave
from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from pydub import AudioSegment
from vosk import Model, KaldiRecognizer

import re

# Load Vosk Speech Model
model = Model("../../../vosk-model-en-us-0.22")

# FastAPI App
app = FastAPI()

# In-memory storage for clients' context
client_context = {}

#In-memory survey questions:
survey_questions = [
    "What is your strongest strength?",
    "What is your biggest weakness?",
    "What area do you want to improve on?"
]

# Join the survey questions into a formatted string
survey_questions_str = "\\n".join(f"{i+1}. {q}" for i, q in enumerate(survey_questions))

# In-memory storage for system prompt
# System prompt with survey questions inserted dynamically
system_prompt = f"""You are a professional survey conductor. 
Your job is to guide the user through a survey.
You ask the user one question at a time and adapt based on the user's response.
You track the survey progress and provide a final summary at the end.
Your goal is to complete the full survey without missing any questions while keeping it conversational.
Your topic should be tightly related to the survey questions only.

Here is the **survey question list**:
{survey_questions_str}

Follow these rules strictly:

1. **FIRST RESPONSE:**  
   - When the user starts with "Hi, let's start. My name is...", greet the user, introduce the survey process, and **immediately** ask the first question.
   - The response **must** be formatted as JSON:
   {{
       "response": "<Greeting user>! <Introduction of the survey process>. First question: <question>.",
       "progress": "0%",
       "finished": false
   }}

2. **MIDDLE RESPONSES:**  
   - For each subsequent user's answers, if the answer seems unclear or incomplete, politely ask for more details or examples. If the answer provides enough information, proceed to the next survey question.
   - The response **must** be formatted as JSON:
   {{
       "response": "<next survey question or follow-up>",
       "progress": "<percentage completed>",
       "finished": false
   }}

3. **LAST QUESTION RESPONSE:**  
   - The last question is always the final question in the survey question list. Once answered, evaluate whether the answer requires clarification or more examples.
     - If the answer seems unclear or incomplete, politely ask for more details or examples.
       - The response **must** be formatted as JSON:
        {{
            "response": "<follow-up>",
            "progress": "<percentage completed>",
            "finished": false
        }}
     - If the answer provides enough information, **provide a thank-you message, a summary of the user's answers to each question in the survey question list, and a farewell** to end the survey.
       - The response **must** be formatted as JSON:
        {{
            "response": "<thank-you message>. Here is the summary of your responses:<summary of user answers to each question in the survey question list>. Thank you for completing the survey! Farewell.",
            "progress": "100%",
            "finished": true
        }}

**Strict Rules:**
- All questions in the **survey question list** **must** be asked in order.
- Every response **must** be strictly formatted as JSON with no extra text.
- Every response **must** end with either a question for the user or a summary of the survey and farewell.
- No question should be asked when the summary and farewell are provided.
- If the user's response is **not relevant** to the current question, guide them back to answering it properly.
- The summary of the survey **must** include the user's answers to each question in the survey question list.
- Only mark finished field in response to true when you include a thank-you message, a summary of the answers, and a farewell.
"""

async def get_ai_response(client_id, client_name, init=True, answer=None):
    """ Asynchronously gets AI response """

    if init:
        client_context[client_id]['history'].append({
            "role": "system",
            "content": system_prompt
        })
        client_context[client_id]['history'].append({
            "role": "user",
            "content": f"Hi, let's start. My name is {client_name}"
        })
    else:
        client_context[client_id]['history'].append({
            "role": "user",
            "content": answer
        })

    url = "http://localhost:6000/conversion"
    payload = {"input": client_context[client_id]['history']}

    print(f"Payload sending to API: {payload}")

    try:
        async with httpx.AsyncClient() as client:
            response = await client.post(url, json=payload, timeout=10.0)
            response.raise_for_status()  # Check for HTTP errors

            # Convert response to JSON
            response_json = response.json()
            print(f"Response from AI service: {response_json}")
            return response_json  # ✅ Proper async return

    except httpx.ConnectTimeout:
        return {"error": "Connection timed out."}  # ✅ Changed yield to return
    except httpx.ReadTimeout:
        return {"error": "Read timeout occurred."}
    except httpx.HTTPStatusError as e:
        return {"error": f"HTTP error: {e.response.status_code} - {e.response.text}"}
    except httpx.RequestError as e:
        return {"error": f"Request error: {e}"}
    except Exception as e:
        return {"error": f"Error: {str(e)}"}

async def process_paragraph(paragraph):
    # Split the paragraph into sentences
    sentences = re.split(r'(?<=[.!?]) +', paragraph)
    
    # Process the sentences in pairs
    for i in range(0, len(sentences), 2):
        sentence_pair = sentences[i:i + 2]
        
        # Get the complete audio data
        audio_data = await get_audio_from_edge(sentence_pair)

        # Encode the audio data as Base64
        audio_base64 = base64.b64encode(audio_data).decode('utf-8')
        
        # Send the audio data back to the client
        yield audio_base64

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

def preprocess_audio_from_socket(client_speech):
    """ Preprocess incoming raw audio (Base64) to WAV format """
    audio_io = BytesIO(client_speech)
    audio = AudioSegment.from_wav(audio_io).set_channels(1).set_frame_rate(16000)

    preprocessed_audio_io = BytesIO()
    audio.export(preprocessed_audio_io, format="wav")
    preprocessed_audio_io.seek(0)
    return preprocessed_audio_io

def transcribe_with_vosk(preprocessed_audio_io):
    """ Speech-to-Text transcription using Vosk """
    wf = wave.open(preprocessed_audio_io, "rb")
    recognizer = KaldiRecognizer(model, wf.getframerate())

    data = wf.readframes(wf.getnframes())
    if recognizer.AcceptWaveform(data):
        result = json.loads(recognizer.Result())['text']
        return result
    return None

@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    """ WebSocket Connection Handler """
    await websocket.accept()
    
    try:
        while True:
            data = await websocket.receive_json()
            type = data.get("type")
            client_id = data.get("client_id")
            client_name = data.get("name")
            audio_base64 = data.get("audio_data")

            # Conversion starts
            if type == 'client_init':
                print(f"received client init message")
                client_context[client_id] = {'history': []}
                
                # Step 1: Stream AI response text and process each chunk
                try:
                    ai_service_reponse = await get_ai_response(client_id, client_name, init=True)
                    response = ai_service_reponse.get("response") 
                    progress = ai_service_reponse.get("progress") 
                    survey_finished = ai_service_reponse.get("finished") 

                    async for audio_base64 in process_paragraph(response):
                        message = {
                            "type": "server_audio_response", 
                            "isFinal": False, 
                            "audioBase64": audio_base64,
                            "surveyProgress": progress,
                            "surveyFinished": survey_finished
                        }
                        
                        await websocket.send_json(message)

                    client_context[client_id]['history'].append({
                        "role": "assistant",
                        "content": response
                    })

                    # Step 2: Send final message
                    message = {
                        "type": "server_audio_response", 
                        "isFinal": True, 
                        "audioBase64": None,
                        "surveyProgress": progress,
                        "surveyFinished": survey_finished
                    }
                    
                    print("sending last chunk of message back to client")
                    await websocket.send_json(message)
                    
                    # Log completion
                    print(f"Completed processing for client {client_id}")
                except Exception as e:
                    print(f"Error in AI response generation: {str(e)}")
            else:
                # Process and transcribe audio
                print(f"received client following message")
                audio_bytes = base64.b64decode(audio_base64)
                preprocessed_audio = preprocess_audio_from_socket(audio_bytes)
                client_text = transcribe_with_vosk(preprocessed_audio)
                
                # Step 1: Stream AI response text and process each chunk
                try:
                    ai_service_reponse = await get_ai_response(client_id, client_name, init=False, answer=client_text)
                    response = ai_service_reponse.get("response") 
                    progress = ai_service_reponse.get("progress") 
                    survey_finished = ai_service_reponse.get("finished") 

                    async for audio_base64 in process_paragraph(response):
                        message = {
                            "type": "server_audio_response", 
                            "isFinal": False, 
                            "audioBase64": audio_base64,
                            "surveyProgress": progress,
                            "surveyFinished": survey_finished
                        }
                        
                        await websocket.send_json(message)

                    client_context[client_id]['history'].append({
                        "role": "assistant",
                        "content": response
                    })

                    # Step 2: Send final message
                    message = {
                        "type": "server_audio_response", 
                        "isFinal": True, 
                        "audioBase64": None,
                        "surveyProgress": progress,
                        "surveyFinished": survey_finished
                    }
                    
                    print("sending last chunk of message back to client")
                    await websocket.send_json(message)
                    
                    # Log completion
                    print(f"Completed processing for client {client_id}")
                except Exception as e:
                    print(f"Error in AI response generation: {str(e)}")
    except WebSocketDisconnect:
        print(f"Client disconnected: {websocket.client}")
