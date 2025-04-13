import os
from dotenv import load_dotenv
from services.vosk_recognizer_manager import VoskRecognizerManager

# Load environment variables (if not already done elsewhere)
def load_env_variables():
    env = os.getenv("ENV", "development")
    dotenv_file = f".env.{env}" if env != "development" else ".env"
    load_dotenv(dotenv_file)

# Get the model path
def get_model_path():
    model_path = os.getenv("VOSK_MODEL_PATH")
    if not model_path:
        raise ValueError("VOSK_MODEL_PATH is not set in the environment file!")
    return model_path

# Create and initialize the recognizer manager
load_env_variables()
recognizer_manager = VoskRecognizerManager(get_model_path())