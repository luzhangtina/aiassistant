# AI Service
It provides /conversion API with response for other service to consume

## Conversion API format
### Endpoint
```
/conversion
```

### Http method
```
POST
```

### Reqeust
```
{
    "input": [
        {
            "role": "system"
            "content": {system_prompt}
        }
        {
            "role": "user",
            "content": "Hi, let's start. My name is ..."
        }
    ]
}
```

### Response
```
header:  text/plain
response body: {JSON string or plain text based on system prompt}
```

### Dependencies
- Ollama
- Python > 3.9
  - Flask
  - Ollama

### Start AI service
1. Run command **python -m venv venv** to create venv directory
2. Run command **source venv/bin/activate** on macOS/Linux to activate the virtual environment
   or run command **venv\Scripts\activate** on Windows to activate the virtual environment
3. Run command **pip install -r requirements.txt** to install the requirement packages
4. Run command **ollama pull llama3.2** to pull Llama 3.2 model
5. Run command **ollama list** to verify Llama 3.2 model exists
5. Run command **python api.py** to start the service
   The service is running on "http://localhost:6000"
6. To stop service, run command **CTRL+C**