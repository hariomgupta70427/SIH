"""
Predictive Maintenance Model for Railway Parts
Predicts part failure probability based on sensor data and usage patterns
"""

import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.preprocessing import StandardScaler
from sklearn.metrics import classification_report, confusion_matrix
import joblib
import warnings
warnings.filterwarnings('ignore')

class PredictiveMaintenanceModel:
    def __init__(self):
        self.model = RandomForestClassifier(n_estimators=100, random_state=42)
        self.scaler = StandardScaler()
        self.feature_columns = None
        
    def load_data(self, file_path=None):
        """Load sensor and maintenance data"""
        if file_path:
            return pd.read_csv(file_path)
        
        # Generate synthetic data for demonstration
        np.random.seed(42)
        n_samples = 10000
        
        data = {
            'part_id': [f'PART_{i:05d}' for i in range(n_samples)],
            'temperature': np.random.normal(75, 15, n_samples),  # Operating temperature
            'vibration': np.random.normal(2.5, 0.8, n_samples),  # Vibration level
            'pressure': np.random.normal(150, 25, n_samples),    # Pressure reading
            'humidity': np.random.normal(45, 10, n_samples),     # Humidity %
            'operating_hours': np.random.uniform(0, 8760, n_samples),  # Hours of operation
            'load_factor': np.random.uniform(0.3, 1.0, n_samples),     # Load percentage
            'maintenance_cycles': np.random.poisson(5, n_samples),      # Previous maintenance
            'age_months': np.random.uniform(1, 60, n_samples),          # Part age
        }
        
        df = pd.DataFrame(data)
        
        # Create failure target based on realistic conditions
        failure_prob = (
            (df['temperature'] > 90) * 0.3 +
            (df['vibration'] > 4.0) * 0.4 +
            (df['operating_hours'] > 7000) * 0.2 +
            (df['age_months'] > 48) * 0.3 +
            np.random.random(n_samples) * 0.1
        )
        
        df['failure_risk'] = (failure_prob > 0.5).astype(int)
        return df
    
    def preprocess_data(self, df):
        """Extract features and prepare data for training"""
        # Feature engineering
        df['temp_vibration_ratio'] = df['temperature'] / (df['vibration'] + 1e-6)
        df['usage_intensity'] = df['operating_hours'] * df['load_factor']
        df['maintenance_efficiency'] = df['maintenance_cycles'] / (df['age_months'] + 1)
        
        # Select feature columns
        self.feature_columns = [
            'temperature', 'vibration', 'pressure', 'humidity',
            'operating_hours', 'load_factor', 'maintenance_cycles', 'age_months',
            'temp_vibration_ratio', 'usage_intensity', 'maintenance_efficiency'
        ]
        
        X = df[self.feature_columns]
        y = df['failure_risk']
        
        return X, y
    
    def train(self, X, y, test_size=0.2):
        """Train the predictive maintenance model"""
        # Split data
        X_train, X_test, y_train, y_test = train_test_split(
            X, y, test_size=test_size, random_state=42, stratify=y
        )
        
        # Scale features
        X_train_scaled = self.scaler.fit_transform(X_train)
        X_test_scaled = self.scaler.transform(X_test)
        
        # Train model
        self.model.fit(X_train_scaled, y_train)
        
        # Evaluate model
        y_pred = self.model.predict(X_test_scaled)
        
        print("Model Performance:")
        print(classification_report(y_test, y_pred))
        
        # Feature importance
        feature_importance = pd.DataFrame({
            'feature': self.feature_columns,
            'importance': self.model.feature_importances_
        }).sort_values('importance', ascending=False)
        
        print("\nFeature Importance:")
        print(feature_importance)
        
        return X_test_scaled, y_test, y_pred
    
    def predict_failure_probability(self, sensor_data):
        """Predict failure probability for new sensor data"""
        if isinstance(sensor_data, dict):
            # Single prediction
            df = pd.DataFrame([sensor_data])
        else:
            df = sensor_data.copy()
        
        # Apply same feature engineering
        df['temp_vibration_ratio'] = df['temperature'] / (df['vibration'] + 1e-6)
        df['usage_intensity'] = df['operating_hours'] * df['load_factor']
        df['maintenance_efficiency'] = df['maintenance_cycles'] / (df['age_months'] + 1)
        
        X = df[self.feature_columns]
        X_scaled = self.scaler.transform(X)
        
        # Get probability predictions
        probabilities = self.model.predict_proba(X_scaled)[:, 1]  # Probability of failure
        predictions = self.model.predict(X_scaled)
        
        return probabilities, predictions
    
    def save_model(self, model_path='models/predictive_maintenance_model.pkl'):
        """Save trained model and scaler"""
        model_data = {
            'model': self.model,
            'scaler': self.scaler,
            'feature_columns': self.feature_columns
        }
        joblib.dump(model_data, model_path)
        print(f"Model saved to {model_path}")
    
    def load_model(self, model_path='models/predictive_maintenance_model.pkl'):
        """Load trained model and scaler"""
        model_data = joblib.load(model_path)
        self.model = model_data['model']
        self.scaler = model_data['scaler']
        self.feature_columns = model_data['feature_columns']
        print(f"Model loaded from {model_path}")

def main():
    """Main training pipeline"""
    # Initialize model
    pm_model = PredictiveMaintenanceModel()
    
    # Load and preprocess data
    print("Loading data...")
    df = pm_model.load_data()
    X, y = pm_model.preprocess_data(df)
    
    print(f"Dataset shape: {X.shape}")
    print(f"Failure rate: {y.mean():.2%}")
    
    # Train model
    print("\nTraining model...")
    X_test, y_test, y_pred = pm_model.train(X, y)
    
    # Save model
    pm_model.save_model()
    
    # Example prediction
    print("\nExample Prediction:")
    sample_data = {
        'temperature': 95,      # High temperature
        'vibration': 4.5,       # High vibration
        'pressure': 160,
        'humidity': 50,
        'operating_hours': 7500, # High usage
        'load_factor': 0.9,
        'maintenance_cycles': 3,
        'age_months': 50        # Old part
    }
    
    prob, pred = pm_model.predict_failure_probability(sample_data)
    print(f"Failure probability: {prob[0]:.2%}")
    print(f"Prediction: {'High Risk' if pred[0] else 'Low Risk'}")

if __name__ == "__main__":
    main()