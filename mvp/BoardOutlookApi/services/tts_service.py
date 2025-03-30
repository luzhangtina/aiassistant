import base64
import edge_tts

async def get_audio_from_edge(text_to_speak):
    print(f"text_to_speak: {text_to_speak}")

    communicate = edge_tts.Communicate(text_to_speak, voice='en-US-AvaMultilingualNeural')
    
    audio_data = bytearray()
    async for response in communicate.stream():
        if isinstance(response, dict) and "data" in response:
            audio_response = response["data"]
            audio_data.extend(audio_response)

    return base64.b64encode(bytes(audio_data)).decode("utf-8")
