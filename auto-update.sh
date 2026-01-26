#!/bin/bash

IMAGE_NAME="sudhsakhala/mlops-disease-predictor:latest"
CONTAINER_NAME="mlops_disease_predictor"

while true; do
    echo "Checking for new image..."
    docker pull $IMAGE_NAME

    NEW_IMAGE_ID=$(docker images -q $IMAGE_NAME)

    CURRENT_IMAGE_ID=$(docker inspect --format='{{.Image}}' $CONTAINER_NAME 2>/dev/null)

    if [ "$NEW_IMAGE_ID" != "$CURRENT_IMAGE_ID" ]; then
        echo "New image detected. Restarting container..."
        if [ $(docker ps -q -f name=$CONTAINER_NAME) ]; then
            docker stop $CONTAINER_NAME
            docker rm $CONTAINER_NAME
        fi

        docker run -d \
            -p 8001:8001 \
            -p 5001:5001 \
            -v "${PWD}/mlruns:/app/mlruns" \
            --name $CONTAINER_NAME \
            $IMAGE_NAME
        echo "Container updated."
    else
        echo "No new image. Container is up-to-date."
    fi

    sleep 60  # check every 60 seconds
done
