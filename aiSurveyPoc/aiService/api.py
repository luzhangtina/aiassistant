from flask import Flask, request, jsonify, Response
from ollama import chat

app = Flask(__name__)

@app.route('/conversion', methods=['POST'])
def next_question():
    input = request.json.get('input')
    
    def generate():
        print(input)
        response = chat(
            model='llama3.2',
            messages=input,
            format='json'
        )
        return response['message']['content']

    return Response(generate(), content_type='text/plain')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=6000)

