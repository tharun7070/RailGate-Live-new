import cv2
import requests
import time
from ultralytics import YOLO
import argparse

# Configuration
API_URL = "http://127.0.0.1:8000"  # Our FastAPI backend
GATE_ID = 1  # The gate we are updating
TRAIN_CLASS_ID = 6  # In COCO dataset, 'train' is class 6

def update_gate_status(status_code):
    """
    Sends a request to the backend to update the gate's status.
    (We will use a new endpoint in the backend for this, or simulate it)
    """
    try:
        # We simulate a "crowdsourced" report from the camera with high accuracy
        payload = {
            "user_id": "camera_bot_01",
            "gate_id": GATE_ID,
            "reported_status": status_code,
            "user_latitude": 19.0760,  # Exact gate 1 location
            "user_longitude": 72.8777,
            "gate_latitude": 19.0760,
            "gate_longitude": 72.8777,
            "user_past_accuracy": 1.0  # Camera is always trusted
        }
        response = requests.post(f"{API_URL}/validate_report", json=payload)
        if response.status_code == 200:
            print(f"[API] Successfully reported status: {'CLOSED' if status_code == 2 else 'OPEN'}")
    except Exception as e:
        print(f"[API Error] Could not connect to backend: {e}")

def process_video(video_path):
    print(f"Loading YOLOv8 model...")
    model = YOLO('yolov8n.pt')  # Loads the nano model (downloads automatically if missing)
    
    print(f"Opening video file: {video_path}")
    cap = cv2.VideoCapture(video_path)
    
    if not cap.isOpened():
        print(f"Error: Could not open video {video_path}")
        return
    
    # State tracking
    is_gate_closed = False
    last_train_seen_time = 0
    cooldown_seconds = 3  # Wait 3 seconds after train leaves before opening gate
    
    frame_count = 0
    
    while cap.isOpened():
        success, frame = cap.read()
        if not success:
            print("Video ended or cannot read frame.")
            break
            
        frame_count += 1
        
        # Process every 5th frame to speed up simulation
        if frame_count % 5 != 0:
            continue
            
        # Run YOLO inference
        results = model(frame, verbose=False)
        
        train_detected = False
        
        # Check if a train is in the frame
        for r in results:
            boxes = r.boxes
            for box in boxes:
                cls = int(box.cls[0])
                if cls == TRAIN_CLASS_ID:
                    train_detected = True
                    break
        
        current_time = time.time()
        
        # State Logic
        if train_detected:
            last_train_seen_time = current_time
            if not is_gate_closed:
                print("🚂 Train detected! Closing gate...")
                is_gate_closed = True
                update_gate_status(2)  # 2 = CLOSED
        else:
            if is_gate_closed and (current_time - last_train_seen_time > cooldown_seconds):
                print("✅ Train has passed. Opening gate...")
                is_gate_closed = False
                update_gate_status(0)  # 0 = OPEN
                
        # Draw results on frame for visualization
        annotated_frame = results[0].plot()
        
        # Add status text
        status_text = "STATUS: CLOSED (Train Detected)" if is_gate_closed else "STATUS: OPEN (Clear)"
        color = (0, 0, 255) if is_gate_closed else (0, 255, 0)
        cv2.putText(annotated_frame, status_text, (50, 50), cv2.FONT_HERSHEY_SIMPLEX, 1, color, 3)
        
        # Display the frame
        cv2.imshow("GateWise Vision Detector", annotated_frame)
        
        # Press 'q' to quit early
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break
            
    cap.release()
    cv2.destroyAllWindows()

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="GateWise Computer Vision Detector")
    parser.add_argument("video_path", help="Path to the video file to process")
    args = parser.parse_args()
    
    process_video(args.video_path)
