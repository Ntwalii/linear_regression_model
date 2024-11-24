from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field
from typing import Optional
import joblib
import numpy as np
import pandas as pd
from fastapi.middleware.cors import CORSMiddleware

# Load model and its information
model_info = joblib.load('solar_model_info.joblib')
model = model_info['model']
scaler = model_info['scaler']
feature_names = model_info['feature_names']

# Initialize FastAPI app
app = FastAPI()

# Enable CORS for cross-origin requests
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Replace with specific domains if needed
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Define Pydantic model for input validation
class PredictionInput(BaseModel):
    Radiation: float = Field(gt=0, description="Radiation must be positive")
    AirTemperature: float = Field(gt=-50, lt=60, description="Air temperature must be between -50°C and 60°C")
    Sunshine: float = Field(gt=0, description="Sunshine duration must be positive")
    Hour_Sin: float = Field(ge=-1, le=1, description="Sine of hour must be between -1 and 1")
    Hour_Cos: float = Field(ge=-1, le=1, description="Cosine of hour must be between -1 and 1")

# Define prediction endpoint
@app.post("/predict")
def predict(input_data: PredictionInput):
    # Convert input data to DataFrame
    input_df = pd.DataFrame([input_data.dict()], columns=feature_names)
    
    # Scale input
    try:
        scaled_input = scaler.transform(input_df)
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Invalid input: {e}")
    
    # Make prediction
    prediction = model.predict(scaled_input)
    prediction_value = round(float(prediction[0]), 2)
    
    return {
        "prediction": prediction_value,
        "unit": "kW"
    }

# Root route
@app.get("/")
def read_root():
    return {"message": "Welcome to the Solar Prediction API"}
