#!/bin/bash

# Script to pull and run the MLops Disease Predictor Docker container

# Pull the latest image
echo "Pulling Docker image sudhsakhala/mlops-disease-predictor:latest..."
docker pull sudhsakhala/mlops-disease-predictor:latest

# Run the container
echo "Running the Docker container..."
docker run -d \
    -p 8001:8001 \
    -p 5001:5001 \
    -v "${PWD}/mlruns:/app/mlruns" \
    --name mlops_disease_predictor \
    sudhsakhala/mlops-disease-predictor:latest

# Check running containers
echo "Container started. Current running containers:"
docker ps
