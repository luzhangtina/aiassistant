# web_socket.py
from fastapi import WebSocket, WebSocketDisconnect
from data.questions import get_survey_data
from services.tts_service import get_audio_from_edge
from services.stt_service import get_text_from_vosk
from data.client_context_store import client_context_store  # Import the global context store
from services.ai_service import compose_ai_messages, get_ai_response
from services.prompt_service import create_system_prompt
from data.magic_word import magic_word
import tempfile
import base64

audio_buffers = {}
wav_headers = {}  # Store the WAV headers separately

async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()

    try:
        while True:
            data = await websocket.receive_json()
            client_id = data['clientId']
            name = data['name']
            type = data['type']

            print(f'CurrentMessageTypeIs: {type}')
            if (type == 'MicrophoneTest'):
                print(f'MicrophoneTest')
            elif (type == 'IsUserReady'):
                print(f'IsUserReady')
            else: 
                # Initialize buffer for this client if needed
                if client_id not in audio_buffers:
                    audio_buffers[client_id] = bytearray()

                user_audio_data_base64 = data.get('audioBase64')

                if user_audio_data_base64:
                    chunk_data = base64.b64decode(user_audio_data_base64)

                    if data.get("isFirstChunk", True):
                        print(f"Received first chunk with WAV header from {client_id}")
                        
                        # The first 44 bytes are the WAV header
                        wav_header = chunk_data[:44]
                        wav_headers[client_id] = wav_header
                        
                        # The rest is audio data
                        audio_data = chunk_data[44:]
                        audio_buffers[client_id].extend(audio_data)
                    else:
                        # For subsequent chunks, just add the audio data
                        audio_buffers[client_id].extend(chunk_data)

                # Check if the chunked audio is complete (you may want to add your own condition here)
                if data.get('isLastChunk', True):
                    # Once all chunks are received, decode and process the complete base64 audio buffer
                    wav_header = wav_headers.get(client_id)
                    if not wav_header:
                        print("WARNING: No WAV header received, creating a default one")
                        wav_header = create_default_wav_header(len(audio_buffers[client_id]))
                    
                    # Update the header with the correct data size
                    updated_header = update_wav_header_size(wav_header, len(audio_buffers[client_id]))
                    
                    # Combine header and audio data
                    complete_audio = bytearray(updated_header) + audio_buffers[client_id]
                    
                    complete_base64_audio = base64.b64encode(complete_audio).decode('utf-8')

                    # with tempfile.NamedTemporaryFile(delete=False, suffix='.wav', mode='wb') as temp_file:
                    #     temp_file.write(complete_audio)
                    #     temp_file_path = temp_file.name

                    # print(f"WAV audio for client {client_id} saved in temp file: {temp_file_path}")

                    # with tempfile.NamedTemporaryFile(delete=False, mode='w') as temp_file:
                    #     temp_file.write(complete_base64_audio)
                    #     temp_file_path = temp_file.name
                    
                    # print(f"Audio data for client {client_id} saved in temp file: {temp_file_path}")
                    
                    if client_id in audio_buffers:
                        del audio_buffers[client_id]
                    if client_id in wav_headers:
                        del wav_headers[client_id]
                    
                    transcript = get_text_from_vosk(complete_base64_audio)

                    print(f"STT result is : {transcript}")

                    user_text_answer = transcript['final_result'] 
                    if not user_text_answer:
                        user_text_answer = transcript['partial_result']

                    try:
                        user_context = client_context_store.get_context(client_id)
                        context = user_context['context']
                        number_of_question_in_progress = context['number_of_current_question']
                        new_question = next(
                            (q['question'] for q in context['questions'] if q['number'] == number_of_question_in_progress),
                            "Question not found"
                        )
                        total_number = context['number_of_total_questions']
                        progress = (number_of_question_in_progress * 100) // total_number

                        history = user_context['history']
                        chat_history = next((entry['chat_history'] for entry in history if entry.get('number_of_question') == number_of_question_in_progress), [])

                        is_survey_completed = False

                        user_responses = [
                            "I believe the board plays a crucial role in shaping and overseeing our long-term strategy. They dedicate time during quarterly meetings specifically to strategic discussions, going beyond routine performance reviews. This ensures that we’re not just reacting to short-term results but actively planning for sustainable growth. The board consistently challenges management’s proposals by asking thought-provoking questions and encouraging alternative perspectives. For example, during our recent expansion planning, they pushed us to consider emerging market risks and diversify our approach, leading to a more resilient strategy. Additionally, they stay informed on external factors — from economic trends to industry disruptions — through regular briefings from experts. This proactive approach helps the organization stay ahead of potential risks and seize new opportunities. Overall, their involvement ensures our strategy remains forward-thinking, adaptable, and aligned with our mission.",
                            "Yes, the board has a clear view of both potential risks and opportunities that could impact the organization’s strategic direction. They don’t just focus on the immediate benefits of any proposal; instead, they assess the long-term implications and sustainability. For example, during our recent expansion plans, the board didn’t just look at the short-term revenue potential; they carefully considered geopolitical risks, the volatility of emerging markets, and technological disruptions. They also encouraged us to evaluate opportunities for innovation and partnerships in those markets, which led to a more diversified risk management strategy. Moreover, they regularly ask management to conduct detailed risk assessments and present contingency plans to ensure we’re prepared for any unexpected shifts in the market or regulatory environment. This broader perspective allows the organization to stay agile and pivot when necessary, ensuring our strategy remains aligned with both external changes and our long-term objectives."
                        ]
                        
                        # Prepare AI response
                        # ai_messages = compose_ai_messages(False, "", user_responses[number_of_question_in_progress-1], chat_history)
                        ai_messages = compose_ai_messages(False, "", user_text_answer, chat_history)
                        ai_response = get_ai_response(ai_messages)

                        user_answer_count = len([msg for msg in ai_messages if msg["role"] == "user"]) - 1

                        print(f"user_answer_count {user_answer_count}")

                        move_on_to_next = magic_word in ai_response or user_answer_count > 1

                        print(f"move_on_to_next {move_on_to_next}")

                        if ( move_on_to_next and number_of_question_in_progress < total_number):
                            if (magic_word in ai_response):
                                # Add ai response to current chat history
                                ai_response = ai_response.replace(magic_word, "").strip()
                                ai_messages.append({
                                    "role": "assistant",
                                    "content": ai_response
                                })
                            else:
                                ai_response = ""

                            # Move to next question
                            number_of_question_in_progress = number_of_question_in_progress + 1

                            new_question = next(
                                (q['question'] for q in context['questions'] if q['number'] == number_of_question_in_progress),
                                "Question not found"
                            )

                            survey_data = context['survey_data']
                            current_survey_data = get_survey_data(survey_data, 1)

                            # Generate system prompt for the AI
                            system_prompt = create_system_prompt(
                                init=False,
                                summary=False,
                                client_name=name,
                                question_text=new_question,
                                description=current_survey_data['description'],
                                chat_history=[],
                                magic_ending_word=magic_word
                            )

                            # Prepare AI response
                            ai_messages = compose_ai_messages(True, system_prompt, "", [])
                            new_ai_response = get_ai_response(ai_messages)

                            # Update client_context
                            ai_messages.append({
                                "role": "assistant",
                                "content": new_ai_response
                            })
                            history.append({
                                "number_of_question": number_of_question_in_progress,
                                "chat_history": ai_messages
                            })

                            # Update context
                            context['number_of_current_question'] = number_of_question_in_progress
                            context['current_question'] = new_question
                            context['progress'] = progress

                            ai_response = f"{ai_response} {new_ai_response}"

                        elif (move_on_to_next and number_of_question_in_progress == total_number):
                            if (magic_word in ai_response):
                                # Add ai response to current chat history
                                ai_response = ai_response.replace(magic_word, "").strip()
                                ai_messages.append({
                                    "role": "assistant",
                                    "content": ai_response
                                })
                            else:
                                ai_response = ""

                            # Get summary of the survey
                            is_survey_completed = True

                            # Compose all question chat history
                            conversation = "\n".join(
                                f"{'Consultant' if message['role'] == 'assistant' else 'User'}: {message['content']}"
                                for entry in history
                                for message in entry.get('chat_history', [])
                                if message.get('role') in ['assistant', 'user']
                            )

                            # Generate system prompt for the AI
                            system_prompt = create_system_prompt(
                                init=False,
                                summary=True,
                                client_name=name,
                                question_text="",
                                description="",
                                chat_history=conversation,
                                magic_ending_word=""
                            )

                            # Prepare AI response
                            user_input = f"Please give me summary of the conversion. The conversion datails is: {conversation}"
                            ai_messages = compose_ai_messages(False, system_prompt, user_input, [])
                            new_ai_response = get_ai_response(ai_messages)

                            # Update client_context
                            user_context['survey_summary'] = new_ai_response

                            ai_response = f"{ai_response} {new_ai_response}"

                        # Generate next audio
                        audio_base64 = await get_audio_from_edge(ai_response)

                        print(f"sending response to user")
                        # Send response
                        await websocket.send_json({
                            "currentNumberOfQuestion": number_of_question_in_progress,
                            "progress": progress,
                            "currentQuestion": new_question,
                            "audioBase64": audio_base64,
                            "isSurveyCompleted": is_survey_completed
                        })

                    except Exception as e:
                        print("Error processing audio:", e)
                else:
                    print(f"Buffered {len(audio_buffers[client_id])} base64 characters for client {client_id}")

    except WebSocketDisconnect:
        print(f"Client disconnected: {websocket.client}")


def print_wav_header_info(header):
    """Print information from a WAV header for debugging"""
    try:
        if len(header) < 44:
            print(f"Invalid WAV header length: {len(header)}")
            return
            
        riff = header[0:4].decode('ascii')
        # chunk_size = int.from_bytes(header[4:8], byteorder='little')
        wave = header[8:12].decode('ascii')
        fmt = header[12:16].decode('ascii')
        # subchunk1_size = int.from_bytes(header[16:20], byteorder='little')
        audio_format = int.from_bytes(header[20:22], byteorder='little')
        num_channels = int.from_bytes(header[22:24], byteorder='little')
        sample_rate = int.from_bytes(header[24:28], byteorder='little')
        byte_rate = int.from_bytes(header[28:32], byteorder='little')
        block_align = int.from_bytes(header[32:34], byteorder='little')
        bits_per_sample = int.from_bytes(header[34:36], byteorder='little')
        data = header[36:40].decode('ascii')
        data_size = int.from_bytes(header[40:44], byteorder='little')
        
        print(f"WAV Header: {riff} {wave} {fmt}")
        print(f"Format: {audio_format} (1=PCM)")
        print(f"Channels: {num_channels}")
        print(f"Sample Rate: {sample_rate}")
        print(f"Bits per Sample: {bits_per_sample}")
        print(f"Byte Rate: {byte_rate}")
        print(f"Block Align: {block_align}")
        print(f"Data: {data}")
        print(f"Data Size: {data_size}")
    except Exception as e:
        print(f"Error parsing WAV header: {e}")
        print(f"Raw header: {header}")

def create_default_wav_header(data_size):
    """Create a default WAV header for 16kHz, 16-bit, mono audio"""
    header = bytearray(44)
    
    # "RIFF"
    header[0:4] = b'RIFF'
    
    # Chunk size (file size - 8)
    chunk_size = data_size + 36
    header[4:8] = chunk_size.to_bytes(4, byteorder='little')
    
    # "WAVE"
    header[8:12] = b'WAVE'
    
    # "fmt "
    header[12:16] = b'fmt '
    
    # Subchunk1 size (16 for PCM)
    header[16:20] = (16).to_bytes(4, byteorder='little')
    
    # Audio format (1 for PCM)
    header[20:22] = (1).to_bytes(2, byteorder='little')
    
    # Num channels (1 for mono)
    header[22:24] = (1).to_bytes(2, byteorder='little')
    
    # Sample rate (16000Hz)
    header[24:28] = (16000).to_bytes(4, byteorder='little')
    
    # Byte rate (SampleRate * NumChannels * BitsPerSample/8)
    header[28:32] = (16000 * 1 * 16 // 8).to_bytes(4, byteorder='little')
    
    # Block align (NumChannels * BitsPerSample/8)
    header[32:34] = (1 * 16 // 8).to_bytes(2, byteorder='little')
    
    # Bits per sample (16)
    header[34:36] = (16).to_bytes(2, byteorder='little')
    
    # "data"
    header[36:40] = b'data'
    
    # Subchunk2 size (data size)
    header[40:44] = data_size.to_bytes(4, byteorder='little')
    
    return header

def update_wav_header_size(header, data_size):
    """Update the size fields in the WAV header"""
    updated = bytearray(header)
    
    # Update chunk size (file size - 8)
    chunk_size = data_size + 36
    updated[4:8] = chunk_size.to_bytes(4, byteorder='little')
    
    # Update data subchunk size
    updated[40:44] = data_size.to_bytes(4, byteorder='little')
    
    return updated

def verify_wav_file(file_path):
    """Verify that a WAV file is valid and readable"""
    try:
        with wave.open(file_path, 'rb') as wav_file:
            channels = wav_file.getnchannels()
            sample_width = wav_file.getsampwidth()
            frame_rate = wav_file.getframerate()
            n_frames = wav_file.getnframes()
            duration = n_frames / frame_rate
            
            print(f"WAV file verification:")
            print(f"  - Channels: {channels}")
            print(f"  - Sample width: {sample_width} bytes")
            print(f"  - Frame rate: {frame_rate} Hz")
            print(f"  - Number of frames: {n_frames}")
            print(f"  - Duration: {duration:.2f} seconds")
            
            # Read a few frames to ensure data is actually there
            first_frames = wav_file.readframes(min(100, n_frames))
            if len(first_frames) > 0:
                print(f"  - First frame data available: {len(first_frames)} bytes")
            else:
                print("  - WARNING: No frame data available")
                
            return True
    except Exception as e:
        print(f"WAV file verification failed: {e}")
        return False