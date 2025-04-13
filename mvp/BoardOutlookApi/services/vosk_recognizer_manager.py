# vosk_manager.py
import json
import base64
import binascii
from vosk import Model, KaldiRecognizer

class VoskRecognizerManager:
    def __init__(self, model_path):
        # Load the Vosk model
        self.model = Model(model_path)
        # Dictionary to store recognizers for each client
        self.recognizers = {}
        # Add dictionaries to store transcripts for each client
        self.final_transcripts = {}
        self.current_partial = {}
        
    def get_recognizer(self, client_id):
        """Get or create a recognizer for a specific client"""
        if client_id not in self.recognizers:
            self.recognizers[client_id] = KaldiRecognizer(self.model, 16000)
        return self.recognizers[client_id]
    
    def remove_client(self, client_id):
        """Clean up resources when a client disconnects"""
        if client_id in self.recognizers:
            del self.recognizers[client_id]
            
    def process_audio(self, audio_base64, client_id):
        # Initialize transcript storage for this client if it doesn't exist
        if client_id not in self.final_transcripts:
            self.final_transcripts[client_id] = ""
        if client_id not in self.current_partial:
            self.current_partial[client_id] = ""

        """Process audio data and return transcription results"""
        # Add padding if necessary
        while len(audio_base64) % 4:
            audio_base64 += b'=' if isinstance(audio_base64, bytes) else '='
        
        try:
            # Decode Base64 to get raw PCM data
            audio_data = base64.b64decode(audio_base64)
        except binascii.Error as e:
            print(f"Base64 decoding error for client {client_id}: {e}")
            return {"final_result": None, "partial_result": ""}
        
        # Get the recognizer for this client
        recognizer = self.get_recognizer(client_id)
        
        # Process the audio data and update transcripts
        final_result = None
        partial_result = None
        
        try:
            if recognizer.AcceptWaveform(audio_data):
                result_json = recognizer.Result()
                final_result = json.loads(result_json).get('text', '')
                
                # If we have a final result, append it to the accumulated transcript
                if final_result:
                    # Add a space if we already have text
                    if self.final_transcripts[client_id]:
                        self.final_transcripts[client_id] += ". "
                    self.final_transcripts[client_id] += final_result
                    # Reset the current partial since we've committed a final result
                    self.current_partial[client_id] = ""
            else:
                partial_json = recognizer.PartialResult()
                partial_result = json.loads(partial_json).get('partial', '')
                # Update the current partial result
                self.current_partial[client_id] = partial_result
        except Exception as e:
            print(f"Error processing audio: {e}")
        
        # Return both the individual segment result and the complete transcript
        return {
            "final_result": final_result,
            "partial_result": partial_result,
            "complete_transcript": self.final_transcripts[client_id],
            "current_partial": self.current_partial[client_id]
        }
        
    def get_complete_transcript(self, client_id):
        """Get the complete transcript including final and current partial"""
        complete = self.final_transcripts.get(client_id, "")
        current_partial = self.current_partial.get(client_id, "")
        
        if complete and current_partial:
            return complete + ". " + current_partial + "."
        elif current_partial:
            return current_partial + "."
        else:
            return complete + "."
    
    def reset_transcript(self, client_id):
        """Reset the transcript for a client - use when starting a new recording"""
        self.final_transcripts[client_id] = ""
        self.current_partial[client_id] = ""
    
    def reset_recognizer(self, client_id):
        """Reset both the recognizer and transcript for a client"""
        if client_id in self.recognizers:
            self.recognizers[client_id] = KaldiRecognizer(self.model, 16000)
        self.reset_transcript(client_id)