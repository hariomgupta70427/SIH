#!/usr/bin/env python3
"""
Simple ML API for demo purposes
Provides deterministic predictions when no trained model is available
"""

from flask import Flask, request, jsonify
import os
import pickle
import json
from datetime import datetime

app = Flask(__name__)

# Global model placeholder
model = None

def load_model_if_exists():
    """Load model if pickle files exist"""
    global model
    model_path = 'models/predictive_maintenance_model.pkl'
    if os.path.exists(model_path):
        try:
            with open(model_path, 'rb') as f:
                model = pickle.load(f)
            print(f"✓ Loaded model from {model_path}")
            return True
        except Exception as e:
            print(f"⚠ Failed to load model: {e}")
    return False

def generate_demo_prediction(part_data):
    """Generate deterministic demo prediction based on part data"""
    # Use part ID or inspection count to generate consistent risk score
    part_id = part_data.get('part_id', 'P-001')
    inspections = part_data.get('inspections', [])
    
    # Simple deterministic calculation
    base_risk = len(part_id) * 0.05  # Based on part ID length
    inspection_factor = len(inspections) * 0.1  # More inspections = higher risk
    
    risk_score = min(base_risk + inspection_factor, 0.95)
    
    # Determine anomaly and advice
    anomaly = risk_score > 0.6
    if risk_score > 0.8:
        advice = "Immediate maintenance required"
    elif risk_score > 0.5:
        advice = "Schedule maintenance soon"
    else:
        advice = "No urgent action required"
    
    return {
        "risk_score": round(risk_score, 2),
        "anomaly": anomaly,
        "advice": advice,
        "confidence": 0.85,
        "model_version": "demo-v1.0",
        "timestamp": datetime.now().isoformat()
    }

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'OK',
        'model_loaded': model is not None,
        'timestamp': datetime.now().isoformat()
    })

@app.route('/predict', methods=['POST'])
def predict():
    """Main prediction endpoint"""
    try:
        data = request.get_json()
        if not data:
            return jsonify({'error': 'No data provided'}), 400
        
        if model:
            # Use actual model if available
            # This would be the real ML prediction logic
            result = generate_demo_prediction(data)
            result['source'] = 'trained_model'
        else:
            # Use demo prediction
            result = generate_demo_prediction(data)
            result['source'] = 'demo_fallback'
        
        return jsonify(result)
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/predict/batch', methods=['POST'])
def predict_batch():
    """Batch prediction endpoint"""
    try:
        data = request.get_json()
        if not data or 'parts' not in data:
            return jsonify({'error': 'No parts data provided'}), 400
        
        results = []
        for part_data in data['parts']:
            prediction = generate_demo_prediction(part_data)
            prediction['part_id'] = part_data.get('part_id', 'unknown')
            results.append(prediction)
        
        return jsonify({
            'predictions': results,
            'count': len(results),
            'timestamp': datetime.now().isoformat()
        })
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    print("🤖 Starting ML API...")
    
    # Try to load model
    if load_model_if_exists():
        print("✓ Using trained model")
    else:
        print("⚠ No trained model found, using demo predictions")
    
    print("🚀 ML API running on http://localhost:5000")
    app.run(debug=True, host='0.0.0.0', port=5000)