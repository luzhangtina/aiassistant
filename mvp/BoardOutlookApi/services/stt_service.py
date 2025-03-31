import base64
import wave
import json
import io
import os
from vosk import Model, KaldiRecognizer
from dotenv import load_dotenv

# Set environment based on your deployment environment
env = os.getenv("ENV", "development")  # Default to "development" if no environment is specified

# Dynamically load the correct .env file
dotenv_file = f".env.{env}" if env != "development" else ".env"
load_dotenv(dotenv_file)

# Now get the VOSK_MODEL_PATH from the environment variables
VOSK_MODEL_PATH = os.getenv("VOSK_MODEL_PATH")

if not VOSK_MODEL_PATH:
    raise ValueError("VOSK_MODEL_PATH is not set in the environment file!")

# Global variable to store the Vosk model
vosk_model = None

def load_vosk_model():
    """ Loads the Vosk model only once and sets it as a global variable. """
    global vosk_model
    if vosk_model is None:  # Ensure it loads only once
        # Load Vosk Speech Model
        vosk_model = Model(VOSK_MODEL_PATH)        

def get_text_from_vosk(audio_base64):
    # Decode Base64

    print(audio_base64)
    print("\n\n")
    
    audio_data = base64.b64decode(audio_base64)

    audio_wav = io.BytesIO(audio_data)

    wf = wave.open(audio_wav, "rb")

    recognizer = KaldiRecognizer(vosk_model, wf.getframerate())
    
    data = wf.readframes(wf.getnframes())

    final_result = None
    partial_result = None

    try:
        # If the recognizer has a final result
        if recognizer.AcceptWaveform(data):
            final_result = json.loads(recognizer.Result())['text']
        else:
            # Get the current partial result
            partial_result = json.loads(recognizer.PartialResult())['partial']
    except json.JSONDecodeError as e:
        print(f"Error decoding JSON: {e}")
    except Exception as e:
        print(f"Unexpected error: {e}")

    # Return both results (final and partial)
    return {"final_result": final_result, "partial_result": partial_result}
