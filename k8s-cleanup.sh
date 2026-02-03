#!/bin/bash

echo "🧹 Starting cleanup for Django + MLflow (K8s + Docker)..."

IMAGE_NAME="sudhsakhala/mlops-disease-predictor:latest"

# -----------------------------
# Kubernetes cleanup
# -----------------------------

echo "➡️ Deleting Service..."
kubectl delete service django-mlflow-service --ignore-not-found

echo "➡️ Deleting Deployment..."
kubectl delete deployment django-mlflow-deployment --ignore-not-found

echo "➡️ Deleting PersistentVolumeClaim..."
kubectl delete pvc mlops-pvc --ignore-not-found

echo "➡️ Deleting PersistentVolume..."
kubectl delete pv mlops-pv --ignore-not-found

# Wait a bit to ensure pods are terminated
sleep 5

# -----------------------------
# Docker cleanup
# -----------------------------

echo "➡️ Deleting Docker image: $IMAGE_NAME"

if docker images | grep -q "sudhsakhala/mlops-disease-predictor"; then
    docker rmi -f $IMAGE_NAME
    echo "✅ Docker image removed"
else
    echo "ℹ️ Docker image not found, skipping"
fi

echo "🎉 Cleanup completed successfully!"
