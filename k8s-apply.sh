#!/bin/bash

# Exit immediately if any command fails
set -e

echo "Applying PV ..."
kubectl apply -f pv.yaml

echo "Applying PVC ..."
kubectl apply -f pvc.yaml

echo "Applying Kubernetes Deployment..."
kubectl apply -f k8s-deployment.yaml

echo "Applying Kubernetes Service..."
kubectl apply -f k8s-service.yml

# echo "Scaling deployment to 3 replicas..."
# kubectl scale deployment django-mlflow-deployment --replicas=3

echo "✅ Deployment applied and scaled successfully!"
