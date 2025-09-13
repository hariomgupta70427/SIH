"""
ML API for Predictive Maintenance and Anomaly Detection
Flask API to serve ML models for real-time predictions
"""

from flask import Flask, request, jsonify
import pandas as pd
import numpy as np
from predictive_maintenance import PredictiveMaintenanceModel
from anomaly_detection import AnomalyDetector
import os

app = Flask(__name__)

# Global model instances
pm_model = None
anomaly_detector = None

def load_models():
    """Load trained models on startup"""
    global pm_model, anomaly_detector
    
    try:
        pm_model = PredictiveMaintenanceModel()
        if os.path.exists('models/predictive_maintenance_model.pkl'):
            pm_model.load_model()
        else:
            print("Training predictive maintenance model...")
            df = pm_model.load_data()
            X, y = pm_model.preprocess_data(df)
            pm_model.train(X, y)
            pm_model.save_model()
        
        anomaly_detector = AnomalyDetector()
        if os.path.exists('models/anomaly_detector.pkl'):
            anomaly_detector.load_model()
        else:
            print("Training anomaly detector...")
            normal_data = anomaly_detector.generate_sensor_data(n_samples=3000, include_anomalies=False)
            anomaly_detector.fit(normal_data)
            anomaly_detector.save_model()
        
        print("Models loaded successfully")
    except Exception as e:
        print(f"Error loading models: {e}")

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'models_loaded': pm_model is not None and anomaly_detector is not None
    })

@app.route('/predict/failure', methods=['POST'])
def predict_failure():
    """Predict failure probability for a part"""
    try:
        data = request.json
        
        # Validate required fields
        required_fields = ['temperature', 'vibration', 'pressure', 'humidity', 
                          'operating_hours', 'load_factor', 'maintenance_cycles', 'age_months']
        
        for field in required_fields:
            if field not in data:
                return jsonify({'error': f'Missing required field: {field}'}), 400
        
        # Make prediction
        probability, prediction = pm_model.predict_failure_probability(data)
        
        # Determine risk level
        risk_level = 'LOW'
        if probability[0] > 0.7:
            risk_level = 'HIGH'
        elif probability[0] > 0.4:
            risk_level = 'MEDIUM'
        
        return jsonify({
            'failure_probability': float(probability[0]),
            'prediction': int(prediction[0]),
            'risk_level': risk_level,
            'recommendations': get_maintenance_recommendations(probability[0], data)
        })
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/detect/anomaly', methods=['POST'])
def detect_anomaly():
    """Detect anomalies in sensor data"""
    try:
        data = request.json
        
        # Handle single reading or batch
        if isinstance(data, dict):
            df = pd.DataFrame([data])
        else:
            df = pd.DataFrame(data)
        
        # Add required fields if missing
        required_fields = ['temperature', 'vibration', 'pressure', 'humidity', 
                          'current', 'voltage', 'rpm', 'load']
        
        for field in required_fields:
            if field not in df.columns:
                df[field] = 0
        
        # Add metadata if missing
        if 'timestamp' not in df.columns:
            df['timestamp'] = pd.Timestamp.now()
        if 'part_id' not in df.columns:
            df['part_id'] = 'UNKNOWN'
        
        # Detect anomalies
        results = anomaly_detector.detect_anomalies(df)
        
        # Format response
        response = []
        for _, row in results.iterrows():
            response.append({
                'part_id': row['part_id'],
                'timestamp': row['timestamp'].isoformat() if pd.notna(row['timestamp']) else None,
                'is_anomaly': bool(row['is_anomaly']),
                'anomaly_score': float(row['anomaly_score']),
                'severity': row['anomaly_severity'],
                'recommendations': get_anomaly_recommendations(row['anomaly_severity'], row)
            })
        
        return jsonify({
            'results': response,
            'summary': anomaly_detector.get_anomaly_summary(results)
        })
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/batch/analyze', methods=['POST'])
def batch_analyze():
    """Analyze batch of sensor data for both failure prediction and anomaly detection"""
    try:
        data = request.json
        df = pd.DataFrame(data)
        
        results = []
        
        for _, row in df.iterrows():
            # Failure prediction
            failure_prob, failure_pred = pm_model.predict_failure_probability(row.to_dict())
            
            # Anomaly detection
            anomaly_result = anomaly_detector.detect_anomalies(pd.DataFrame([row]))
            
            results.append({
                'part_id': row.get('part_id', 'UNKNOWN'),
                'failure_probability': float(failure_prob[0]),
                'failure_prediction': int(failure_pred[0]),
                'is_anomaly': bool(anomaly_result['is_anomaly'].iloc[0]),
                'anomaly_severity': anomaly_result['anomaly_severity'].iloc[0],
                'overall_risk': calculate_overall_risk(failure_prob[0], anomaly_result['is_anomaly'].iloc[0])
            })
        
        return jsonify({'results': results})
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500

def get_maintenance_recommendations(probability, sensor_data):
    """Generate maintenance recommendations based on failure probability"""
    recommendations = []
    
    if probability > 0.8:
        recommendations.append("URGENT: Schedule immediate maintenance")
        recommendations.append("Replace part within 24 hours")
    elif probability > 0.6:
        recommendations.append("Schedule maintenance within 1 week")
        recommendations.append("Increase monitoring frequency")
    elif probability > 0.4:
        recommendations.append("Plan maintenance within 1 month")
        recommendations.append("Monitor key parameters closely")
    
    # Specific recommendations based on sensor values
    if sensor_data.get('temperature', 0) > 90:
        recommendations.append("Check cooling system")
    if sensor_data.get('vibration', 0) > 4:
        recommendations.append("Inspect for mechanical wear")
    if sensor_data.get('operating_hours', 0) > 7000:
        recommendations.append("Consider part replacement due to age")
    
    return recommendations

def get_anomaly_recommendations(severity, sensor_data):
    """Generate recommendations based on anomaly severity"""
    recommendations = []
    
    if severity == 'Critical':
        recommendations.append("CRITICAL: Stop operation immediately")
        recommendations.append("Investigate root cause")
    elif severity == 'High':
        recommendations.append("Reduce operational load")
        recommendations.append("Schedule inspection within 24 hours")
    elif severity == 'Medium':
        recommendations.append("Monitor closely")
        recommendations.append("Schedule routine inspection")
    
    return recommendations

def calculate_overall_risk(failure_prob, is_anomaly):
    """Calculate overall risk score combining failure prediction and anomaly detection"""
    risk_score = failure_prob * 0.7  # Weight failure prediction more
    
    if is_anomaly:
        risk_score += 0.3  # Add anomaly penalty
    
    if risk_score > 0.8:
        return 'CRITICAL'
    elif risk_score > 0.6:
        return 'HIGH'
    elif risk_score > 0.4:
        return 'MEDIUM'
    else:
        return 'LOW'

if __name__ == '__main__':
    load_models()
    app.run(debug=True, host='0.0.0.0', port=5000)