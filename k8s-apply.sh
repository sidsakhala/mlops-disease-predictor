#!/bin/bash

# Exit immediately if any command fails
set -e

echo "Applying Kubernetes Deployment..."
kubectl apply -f deployment.yaml

echo "Applying Kubernetes Service..."
kubectl apply -f k8s-service.yml

echo "Scaling deployment to 3 replicas..."
kubectl scale deployment django-mlflow-deployment --replicas=3

echo "✅ Deployment applied and scaled successfully!"
