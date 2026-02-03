# Base image
FROM python:3.10-slim

# Environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Working directory
WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --upgrade pip && pip install -r requirements.txt

# Copy project
COPY . .

# Create MLflow directory (will be backed by PV)
RUN mkdir -p /mlflow

# Expose ports
EXPOSE 8001 5001

# Start MLflow server + Django
CMD bash -c "\
mlflow server \
  --host 0.0.0.0 \
  --port 5001 \
  --backend-store-uri sqlite:////mlflow/mlflow.db \
  --default-artifact-root /mlflow/artifacts & \
python manage.py runserver 0.0.0.0:8001 \
"
