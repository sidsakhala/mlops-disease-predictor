# Base image
FROM python:3.10-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Set working directory
WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --upgrade pip && pip install -r requirements.txt

# Copy project
COPY . .


# Expose port
EXPOSE 8001 5001

# Run server
# Start MLflow UI and Django server
CMD bash -c "\
    mlflow ui --host 0.0.0.0 --port 5001 --backend-store-uri /app/mlruns & \
    python manage.py runserver 0.0.0.0:8001 \
"
