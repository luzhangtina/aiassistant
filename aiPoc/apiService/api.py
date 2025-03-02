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
import asyncio

# Load Vosk Speech Model
model = Model("../../../vosk-model-en-us-0.22")

# FastAPI App
app = FastAPI()

# In-memory storage for clients' context
client_context = {}

async def get_ai_response(client_id, client_name, init=True, answer=None):
    """ Asynchronously gets AI response in chunks """
    if init:
        client_context[client_id]['history'].append({
            "role": "user",
            "content": f"Hi, let's start. My name is {client_name}"
        })
    else:
        client_context[client_id]['history'].append({
            "role": "user",
            "content": answer
        })

    url = "http://localhost:5000/conversion"
    payload = {"input": client_context[client_id]['history']}

    print(f"payload sending to API: {payload}")

    try:
        async with httpx.AsyncClient() as client:
            async with client.stream("POST", url, json=payload, timeout=10.0) as response:
                response.raise_for_status()  # Check for HTTP errors
                full_response = []  # Store chunks in a list
                async for chunk in response.aiter_text(chunk_size=2048):
                    full_response.append(chunk) 

                full_text = "".join(full_response)
                full_text = full_text.replace('\n', ' ')
                yield full_text

    except httpx.ConnectTimeout:
        yield "Error: Connection timed out."
    except httpx.ReadTimeout:
        yield "Error: Read timeout occurred."
    except httpx.HTTPStatusError as e:
        yield f"HTTP error: {e.response.status_code} - {e.response.text}"
    except httpx.RequestError as e:
        yield f"Request error: {e}"
    except Exception as e:
        yield f"Error: {str(e)}"

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

            full_response = []
            # Conversion starts
            if type == 'client_init':
                print(f"received client init message")
                client_context[client_id] = {'history': []}
                
                # Step 1: Stream AI response text and process each chunk
                try:
                    async for text_chunk in get_ai_response(client_id, client_name, init=True):
                        try:
                            full_response.append(text_chunk)
                            async for audio_base64 in process_paragraph(text_chunk):
                                message = {"type": "server_audio_response", "isFinal": False, "audioBase64": audio_base64}
                                await websocket.send_json(message)
                        except asyncio.TimeoutError:
                            print(f"Timeout while processing audio for chunk: {text_chunk[:50]}...")
                            # Continue with next chunk instead of completely failing
                            continue
                        except Exception as e:
                            print(f"Error processing audio: {str(e)}")
                            # Continue with next chunk
                            continue
                except Exception as e:
                    print(f"Error in AI response generation: {str(e)}")
                
                client_context[client_id]['history'].append({
                    "role": "assistant",
                    "content": "".join(full_response)
                })

                # Step 2: Send final message regardless of timeout issues
                message = {"type": "server_audio_response", "isFinal": True, "audioBase64": None}
                print("sending last chunk of message back to client")
                await websocket.send_json(message)
                
                # Log completion
                print(f"Completed processing for client {client_id}")
            else:
                # Process and transcribe audio
                print(f"received client following message")
                audio_bytes = base64.b64decode(audio_base64)
                preprocessed_audio = preprocess_audio_from_socket(audio_bytes)
                client_text = transcribe_with_vosk(preprocessed_audio)

                # Step 1: Stream AI response text and process each chunk
                try:
                    async for text_chunk in get_ai_response(client_id, client_name, init=False, answer=client_text):
                        try:
                            full_response.append(text_chunk)
                            async for audio_base64 in process_paragraph(text_chunk):
                                message = {"type": "server_audio_response", "isFinal": False, "audioBase64": audio_base64}
                                await websocket.send_json(message)
                        except asyncio.TimeoutError:
                            print(f"Timeout while processing audio for chunk: {text_chunk[:50]}...")
                            # Continue with next chunk instead of completely failing
                            continue
                        except Exception as e:
                            print(f"Error processing audio: {str(e)}")
                            # Continue with next chunk
                            continue
                except Exception as e:
                    print(f"Error in AI response generation: {str(e)}")
                
                client_context[client_id]['history'].append({
                    "role": "assistant",
                    "content": "".join(full_response)
                })
                
                # Step 2: Send final message regardless of timeout issues
                message = {"type": "server_audio_response", "isFinal": True, "audioBase64": None}
                print("sending last chunk of message to client")
                await websocket.send_json(message)
                
                # Log completion
                print(f"Completed processing for client {client_id}")
    except WebSocketDisconnect:
        print(f"Client disconnected: {websocket.client}")
