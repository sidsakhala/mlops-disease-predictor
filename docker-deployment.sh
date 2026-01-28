#!/bin/bash

IMAGE_NAME="sudhsakhala/mlops-disease-predictor:latest"
CONTAINER_NAME="mlops_disease_predictor"

while true; do
    echo "Checking for new image..."

    docker pull $IMAGE_NAME

    NEW_IMAGE_ID=$(docker inspect --format='{{.Id}}' $IMAGE_NAME)

    if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        CURRENT_IMAGE_ID=$(docker inspect --format='{{.Image}}' $CONTAINER_NAME)
    else
        CURRENT_IMAGE_ID=""
    fi

    if [ "$NEW_IMAGE_ID" != "$CURRENT_IMAGE_ID" ]; then
        echo "New image detected. Restarting container..."

        if docker ps -q -f name=$CONTAINER_NAME >/dev/null; then
            docker stop $CONTAINER_NAME
            docker rm $CONTAINER_NAME
        fi

        docker run -d \
            --restart unless-stopped \
            -p 8001:8001 \
            -p 5001:5001 \
            -v "$(pwd)/mlruns:/app/mlruns" \
            --name $CONTAINER_NAME \
            $IMAGE_NAME

        echo "Container updated successfully."
    else
        echo "No new image. Container is up-to-date."
    fi

    sleep 60
done
