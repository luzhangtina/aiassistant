import httpx
from typing import Dict, Any
from ollama import chat
import html
import re

def compose_ai_messages(init, prompt, answer, messages):
    """Composes the payload for the AI service."""

    # Define user introduction if initializing
    if init:
        messages = [{
            "role": "system",
            "content": prompt
        },
        {
            "role": "user",
            "content": "Hi, let's start."
        }]
    else:
        # If it's a follow-up question, add the user's answer to history
        messages.append({
            "role": "user",
            "content": answer
        })

    return messages
    
def get_ai_response(messages) -> str:
    print(f"messages sent to AI model: {messages}")

    response = chat(
        model='llama3.2',
        messages=messages
    )
    ai_message = response['message']['content']

    # Decode any HTML entities (e.g., &quot; -> ")
    ai_message = html.unescape(ai_message)
    
    # Remove non-standard characters like emojis or icons
    ai_message = re.sub(r'[^\x00-\x7F]+', '', ai_message)

    # Remove parentheses, square brackets, curly braces, *, ~ and other special characters
    ai_message = re.sub(r'[()\[\]{}*~`^_+<>|=\\/-]', '', ai_message)

    # Collapse multiple spaces, newlines, or tabs into a single space
    ai_message = re.sub(r'\s+', ' ', ai_message)

    # Strip leading/trailing spaces
    result = ai_message.strip()

    print(f"messages got from AI model: {result}")

    return result
