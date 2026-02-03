#!/bin/bash

echo "🧹 Starting Kubernetes cleanup for Django + MLflow..."

# Delete Service
echo "➡️ Deleting Service..."
kubectl delete service django-mlflow-service --ignore-not-found

# Delete Deployment
echo "➡️ Deleting Deployment..."
kubectl delete deployment django-mlflow-deployment --ignore-not-found

# Delete PVC
echo "➡️ Deleting PersistentVolumeClaim..."
kubectl delete pvc mlops-pvc --ignore-not-found

# Delete PV
echo "➡️ Deleting PersistentVolume..."
kubectl delete pv mlops-pv --ignore-not-found

echo "✅ Cleanup completed successfully!"
