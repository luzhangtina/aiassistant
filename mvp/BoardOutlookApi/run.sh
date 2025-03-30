#!/bin/bash

# Step 3: Create a virtual environment
echo "Creating virtual environment..."
python3 -m venv venv

# Step 4: Activate the virtual environment
echo "Activating virtual environment..."
source venv/bin/activate

# Step 5: Install required packages
echo "Installing required packages from requirements.txt..."
pip install -r requirements.txt

# Step 6: Start the API service
echo "Starting the API service on ws://localhost:8001..."
uvicorn main:app --host localhost --port 8001

# Step 7: To stop the service, press CTRL+C
