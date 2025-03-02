# AI Service
It provides /conversion API with response stream for other service to consume

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
            "role": "user",
            "content": "Hi, let's start. My name is ..."
        }
    ]
}
```

### Response
```
header:  text/plain
response body: "Hi, how are you today?"
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
4. Run command **python surveyModel.py** to create LLM model surveyModel
5. Run command **ollama list** to verify the surveyModel is created
6. Run command **python api.py** to start the service
   The service is running on "http://localhost:5000"
7. To stop service, run command **CTRL+C**