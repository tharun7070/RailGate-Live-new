from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import joblib
import pandas as pd
from datetime import datetime
import os
import math

app = FastAPI(title="GateWise ML Backend", description="AI/ML features for GateWise app")

# Load model at startup
MODEL_PATH = "models/gate_prediction_model.pkl"
model = None

@app.on_event("startup")
def load_model():
    global model
    if os.path.exists(MODEL_PATH):
        model = joblib.load(MODEL_PATH)
        print(f"Loaded ML model from {MODEL_PATH}")
    else:
        print(f"Warning: Model not found at {MODEL_PATH}. Run train_model.py first.")

class PredictionRequest(BaseModel):
    gate_id: int

class PredictionResponse(BaseModel):
    gate_id: int
    predicted_status: int # 0=Open, 1=Likely to Close, 2=Closed
    confidence: float
    timestamp: str

class TrustScoreRequest(BaseModel):
    user_id: str
    gate_id: int
    reported_status: int
    user_latitude: float
    user_longitude: float
    gate_latitude: float
    gate_longitude: float
    user_past_accuracy: float # Between 0.0 and 1.0

class TrustScoreResponse(BaseModel):
    trust_score: float # 0.0 to 1.0
    is_valid: bool
    reason: str

def calculate_distance(lat1, lon1, lat2, lon2):
    # Haversine formula
    R = 6371  # Radius of earth in km
    dLat = math.radians(lat2 - lat1)
    dLon = math.radians(lon2 - lon1)
    a = math.sin(dLat/2) * math.sin(dLat/2) + \
        math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * \
        math.sin(dLon/2) * math.sin(dLon/2)
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1-a))
    d = R * c
    return d

@app.get("/")
def read_root():
    return {"status": "GateWise ML Backend is running!"}

@app.post("/predict", response_model=PredictionResponse)
def predict_gate_status(request: PredictionRequest):
    if model is None:
        raise HTTPException(status_code=503, detail="ML model is not loaded.")
        
    now = datetime.now()
    
    # Prepare features
    features = pd.DataFrame([{
        'hour': now.hour,
        'minute': now.minute,
        'day_of_week': now.weekday(),
        'gate_id': request.gate_id
    }])
    
    # Predict
    predicted_class = model.predict(features)[0]
    probabilities = model.predict_proba(features)[0]
    confidence = float(probabilities[predicted_class])
    
    return PredictionResponse(
        gate_id=request.gate_id,
        predicted_status=int(predicted_class),
        confidence=confidence,
        timestamp=now.isoformat()
    )

@app.post("/validate_report", response_model=TrustScoreResponse)
def validate_crowdsourced_report(request: TrustScoreRequest):
    # Base score depends on historical accuracy
    trust_score = request.user_past_accuracy * 0.5
    
    # Distance penalty
    distance_km = calculate_distance(
        request.user_latitude, request.user_longitude,
        request.gate_latitude, request.gate_longitude
    )
    
    # If user is within 100 meters, give high boost. 
    # If more than 500 meters, penalize heavily.
    distance_factor = 0.0
    if distance_km < 0.1:
        distance_factor = 0.5
    elif distance_km < 0.5:
        distance_factor = 0.2
    else:
        # Too far to reliably report
        return TrustScoreResponse(
            trust_score=0.1,
            is_valid=False,
            reason="User is too far from the gate to report accurately."
        )
        
    trust_score += distance_factor
    
    # Cap at 1.0
    trust_score = min(1.0, trust_score)
    
    is_valid = trust_score >= 0.6
    
    reason = "Report looks valid." if is_valid else "Trust score too low (check user history or location)."
    
    return TrustScoreResponse(
        trust_score=round(trust_score, 2),
        is_valid=is_valid,
        reason=reason
    )
