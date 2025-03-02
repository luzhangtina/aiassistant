#!/bin/bash

# Step 1: Create a virtual environment
echo "Creating virtual environment..."
python3 -m venv venv

# Step 2: Activate the virtual environment
echo "Activating virtual environment..."
source venv/bin/activate

# Step 3: Install required packages
echo "Installing required packages from requirements.txt..."
pip install -r requirements.txt

# Step 4: Pull llama3.2 model
echo "Pulling llama3.2 model..."
ollama pull llama3.2

# Step 5: Create surveyModel based on llama3.2 model
# echo "Creating surveyModel based on llama3.2 model..."
# python surveyModel.py

# Step 6: Verify that surveyModel is created
echo "Verifying surveyModel creation..."
ollama list

# Step 7: Start the service
echo "Starting the service on http://localhost:5000..."
python api.py

# Step 8: To stop the service, press CTRL+C
