import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score
import joblib
import os

# Set random seed for reproducibility
np.random.seed(42)

def generate_synthetic_data(num_records=5000):
    print(f"Generating {num_records} synthetic records for training...")
    
    # Features:
    # 1. Hour of the day (0-23)
    # 2. Minute of the hour (0-59)
    # 3. Day of the week (0-6)
    # 4. Gate ID (numeric representation)
    
    hours = np.random.randint(0, 24, num_records)
    minutes = np.random.randint(0, 60, num_records)
    days = np.random.randint(0, 7, num_records)
    gate_ids = np.random.randint(1, 6, num_records) # Gates 1 to 5
    
    # Target: 0 = Open, 1 = Likely to Close (within next 15 mins), 2 = Closed
    status = []
    
    for i in range(num_records):
        h = hours[i]
        m = minutes[i]
        g = gate_ids[i]
        d = days[i]
        
        # Artificial logic to simulate train schedules
        # Example: Gate 1 closes often between 8:00-9:00 AM and 5:00-6:00 PM on weekdays
        if g == 1 and d < 5 and ((h == 8) or (h == 17)):
            # 70% chance of being closed or likely to close
            val = np.random.choice([0, 1, 2], p=[0.3, 0.3, 0.4])
        # Example: Gate 2 closes at specific minutes past the hour (train every hour at :30)
        elif g == 2 and 25 <= m <= 40:
            val = np.random.choice([0, 1, 2], p=[0.1, 0.4, 0.5])
        # Random noise for other times
        else:
            val = np.random.choice([0, 1, 2], p=[0.8, 0.1, 0.1])
            
        status.append(val)
        
    df = pd.DataFrame({
        'hour': hours,
        'minute': minutes,
        'day_of_week': days,
        'gate_id': gate_ids,
        'status': status
    })
    
    return df

def train_and_save_model():
    # 1. Generate Data
    df = generate_synthetic_data()
    
    # 2. Prepare Features (X) and Target (y)
    X = df[['hour', 'minute', 'day_of_week', 'gate_id']]
    y = df['status']
    
    # 3. Split data
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
    
    # 4. Train Model
    print("Training Random Forest model...")
    model = RandomForestClassifier(n_estimators=100, max_depth=10, random_state=42)
    model.fit(X_train, y_train)
    
    # 5. Evaluate
    y_pred = model.predict(X_test)
    acc = accuracy_score(y_test, y_pred)
    print(f"Model Accuracy on Test Data: {acc:.2f}")
    
    # 6. Save Model
    model_dir = 'models'
    os.makedirs(model_dir, exist_ok=True)
    model_path = os.path.join(model_dir, 'gate_prediction_model.pkl')
    joblib.dump(model, model_path)
    print(f"Model saved successfully to {model_path}")

if __name__ == "__main__":
    train_and_save_model()
