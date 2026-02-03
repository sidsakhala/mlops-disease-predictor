from django.shortcuts import render
import numpy as np
import pandas as pd
from sklearn.ensemble import RandomForestClassifier
from sklearn.neighbors import KNeighborsClassifier
from predictor.forms import BreastCancerForm, DiabetesForm, HeartDiseaseForm
from .models import *
import mlflow
import mlflow.sklearn
import os

from sklearn.metrics import (
    accuracy_score,
    precision_score,
    recall_score,
    f1_score,
    roc_auc_score
)


# --------------------------------------------------
# MLflow basic configuration
# --------------------------------------------------

# MLFLOW_TRACKING_URI = "mlruns"
# MLFLOW_TRACKING_URI = "file:/app/mlruns"

MLFLOW_TRACKING_URI = os.getenv(
    "MLFLOW_TRACKING_URI",
    "http://localhost:5001"
)

mlflow.set_tracking_uri(MLFLOW_TRACKING_URI)
# mlflow.set_tracking_uri("http://localhost:5001")


# --------------------------------------------------
# Generic MLflow experiment-based trainer
# --------------------------------------------------

def train_model_with_experiment(
    experiment_name,
    model_name,
    X,
    Y,
    model_type="rf",
    params=None,
    run_name=None
):
    """
    Train a model and log metrics + model to MLflow
    """

    mlflow.set_experiment(experiment_name)

    with mlflow.start_run(run_name=run_name):

        if model_type == "rf":
            model = RandomForestClassifier(**params)
        elif model_type == "knn":
            model = KNeighborsClassifier(**params)
        else:
            raise ValueError("Unsupported model_type")

        X_clean = np.nan_to_num(X)

        # ------------------
        # Train
        # ------------------
        model.fit(X_clean, Y)

        # ------------------
        # Predictions
        # ------------------
        y_pred = model.predict(X_clean)

        # Some models support predict_proba (needed for AUC)
        if hasattr(model, "predict_proba"):
            y_prob = model.predict_proba(X_clean)[:, 1]
            auc = roc_auc_score(Y, y_prob)
        else:
            auc = None

        # ------------------
        # Metrics
        # ------------------
        accuracy = accuracy_score(Y, y_pred)
        precision = precision_score(Y, y_pred, zero_division=0)
        recall = recall_score(Y, y_pred, zero_division=0)
        f1 = f1_score(Y, y_pred, zero_division=0)

        # ------------------
        # Log to MLflow
        # ------------------
        mlflow.log_param("model_type", model_type)
        mlflow.log_params(params)

        mlflow.log_metric("accuracy", accuracy)
        mlflow.log_metric("precision", precision)
        mlflow.log_metric("recall", recall)
        mlflow.log_metric("f1_score", f1)

        if auc is not None:
            mlflow.log_metric("auc_roc", auc)

        # Log model
        mlflow.sklearn.log_model(model, artifact_path=model_name)

    return model



# --------------------------------------------------
# Heart Disease View
# --------------------------------------------------

def heart(request):
    df = pd.read_csv('static/Heart_train.csv')
    X = df.iloc[:, :-1].values
    Y = df.iloc[:, -1].values

    value = ''

    if request.method == 'POST':
        fields = [
            'age','sex','cp','trestbps','chol','fbs',
            'restecg','thalach','exang','oldpeak',
            'slope','ca','thal'
        ]

        user_values = [float(request.POST[field]) for field in fields]
        user_data = np.array(user_values).reshape(1, -1)

        rf = train_model_with_experiment(
            experiment_name="Heart_Disease_Experiment",
            model_name="heart_rf_model",
            X=X,
            Y=Y,
            model_type="rf",
            params={
                "n_estimators": 16,
                "criterion": "entropy",
                "max_depth": 9
            },
            run_name="RF_depth_9_estimators_16"
        )

        prediction = rf.predict(user_data)
        value = "have" if int(prediction[0]) == 1 else "don't have"

    return render(request, 'heart.html', {
        'result': value,
        'title': 'Heart Disease Prediction',
        'active': 'btn btn-success peach-gradient text-black',
        'heart': True,
        'form': HeartDiseaseForm(),
    })


# --------------------------------------------------
# Diabetes View
# --------------------------------------------------

def diabetes(request):
    X = pd.read_csv('static/Diabetes_XTrain.csv').values
    Y = pd.read_csv('static/Diabetes_YTrain.csv').values.reshape(-1)

    value = ''

    if request.method == 'POST':
        fields = [
            'pregnancies','glucose','bloodpressure',
            'skinthickness','bmi','insulin',
            'pedigree','age'
        ]

        user_values = [float(request.POST[field]) for field in fields]
        user_data = np.array(user_values).reshape(1, -1)

        knn = train_model_with_experiment(
            experiment_name="Diabetes_Experiment",
            model_name="diabetes_knn_model",
            X=X,
            Y=Y,
            model_type="knn",
            params={
                "n_neighbors": 3
            },
            run_name="KNN_k_3"
        )

        prediction = knn.predict(user_data)
        value = "have" if int(prediction[0]) == 1 else "don't have"

    return render(request, 'diabetes.html', {
        'result': value,
        'title': 'Diabetes Disease Prediction',
        'active': 'btn btn-success peach-gradient text-white',
        'diabetes': True,
        'form': DiabetesForm(),
    })


# --------------------------------------------------
# Breast Cancer View
# --------------------------------------------------

def breast(request):
    df = pd.read_csv('static/Breast_train.csv')
    X = df.iloc[:, :-1].values
    Y = df.iloc[:, -1].values

    value = ''

    if request.method == 'POST':
        fields = ['radius','texture','perimeter','area','smoothness']
        user_values = [float(request.POST[field]) for field in fields]
        user_data = np.array(user_values).reshape(1, -1)

        rf = train_model_with_experiment(
            experiment_name="Breast_Cancer_Experiment",
            model_name="breast_rf_model",
            X=X,
            Y=Y,
            model_type="rf",
            params={
                "n_estimators": 15,
                "criterion": "entropy",
                "max_depth": 7
            },
            run_name="RF_depth_7"
        )

        prediction = rf.predict(user_data)
        value = "have" if int(prediction[0]) == 1 else "don't have"

    return render(request, 'breast.html', {
        'result': value,
        'title': 'Breast Cancer Prediction',
        'active': 'btn btn-success peach-gradient text-white',
        'breast': True,
        'form': BreastCancerForm(),
    })


# --------------------------------------------------
# Home & Error Views
# --------------------------------------------------

def home(request):
    name = BreastCancer.objects.all()
    return render(request, 'home.html', {'name': name})


def handler404(request):
    return render(request, '404.html', status=404)
