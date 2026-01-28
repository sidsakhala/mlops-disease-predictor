#!/bin/bash

# Exit on any error
set -e

echo "Deleting Kubernetes deployment..."
kubectl delete deployment django-mlflow-deployment --ignore-not-found

echo "Deleting Kubernetes service..."
kubectl delete svc django-mlflow-service
