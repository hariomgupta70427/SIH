"""
Anomaly Detection for Railway Parts Sensor Data
Detects unusual patterns in sensor readings that may indicate potential issues
"""

import pandas as pd
import numpy as np
from sklearn.ensemble import IsolationForest
from sklearn.preprocessing import StandardScaler
from sklearn.decomposition import PCA
import joblib
import warnings
warnings.filterwarnings('ignore')

class AnomalyDetector:
    def __init__(self, contamination=0.1):
        """
        Initialize anomaly detector
        contamination: Expected proportion of anomalies in dataset (0.1 = 10%)
        """
        self.isolation_forest = IsolationForest(
            contamination=contamination,
            random_state=42,
            n_estimators=100
        )
        self.scaler = StandardScaler()
        self.pca = PCA(n_components=0.95)  # Keep 95% of variance
        self.feature_columns = None
        self.is_fitted = False
    
    def generate_sensor_data(self, n_samples=5000, include_anomalies=True):
        """Generate synthetic sensor data with optional anomalies"""
        np.random.seed(42)
        
        # Normal operating conditions
        normal_data = {
            'temperature': np.random.normal(75, 10, n_samples),
            'vibration': np.random.normal(2.0, 0.5, n_samples),
            'pressure': np.random.normal(150, 15, n_samples),
            'humidity': np.random.normal(45, 8, n_samples),
            'current': np.random.normal(12, 2, n_samples),
            'voltage': np.random.normal(24, 1, n_samples),
            'rpm': np.random.normal(1800, 100, n_samples),
            'load': np.random.normal(0.7, 0.15, n_samples),
        }
        
        df = pd.DataFrame(normal_data)
        
        if include_anomalies:
            # Inject anomalies (10% of data)
            n_anomalies = int(n_samples * 0.1)
            anomaly_indices = np.random.choice(n_samples, n_anomalies, replace=False)
            
            # Different types of anomalies
            for i in anomaly_indices[:n_anomalies//3]:
                # High temperature anomaly
                df.loc[i, 'temperature'] = np.random.uniform(100, 120)
                df.loc[i, 'vibration'] = np.random.uniform(4, 6)
            
            for i in anomaly_indices[n_anomalies//3:2*n_anomalies//3]:
                # Electrical anomaly
                df.loc[i, 'current'] = np.random.uniform(20, 30)
                df.loc[i, 'voltage'] = np.random.uniform(18, 22)
            
            for i in anomaly_indices[2*n_anomalies//3:]:
                # Mechanical anomaly
                df.loc[i, 'vibration'] = np.random.uniform(5, 8)
                df.loc[i, 'rpm'] = np.random.uniform(2200, 2500)
        
        # Add timestamp
        df['timestamp'] = pd.date_range('2024-01-01', periods=n_samples, freq='1H')
        df['part_id'] = [f'PART_{i%100:03d}' for i in range(n_samples)]
        
        return df
    
    def preprocess_data(self, df):
        """Preprocess sensor data for anomaly detection"""
        # Select sensor columns
        self.feature_columns = [
            'temperature', 'vibration', 'pressure', 'humidity',
            'current', 'voltage', 'rpm', 'load'
        ]
        
        # Feature engineering
        df['temp_vibration_product'] = df['temperature'] * df['vibration']
        df['power'] = df['current'] * df['voltage']
        df['efficiency'] = df['load'] / (df['power'] + 1e-6)
        
        # Add engineered features
        self.feature_columns.extend(['temp_vibration_product', 'power', 'efficiency'])
        
        X = df[self.feature_columns].fillna(0)
        return X
    
    def fit(self, df):
        """Fit anomaly detector on normal data"""
        X = self.preprocess_data(df)
        
        # Scale features
        X_scaled = self.scaler.fit_transform(X)
        
        # Apply PCA for dimensionality reduction
        X_pca = self.pca.fit_transform(X_scaled)
        
        # Fit Isolation Forest
        self.isolation_forest.fit(X_pca)
        self.is_fitted = True
        
        print(f"Anomaly detector fitted on {len(X)} samples")
        print(f"Features: {len(self.feature_columns)}")
        print(f"PCA components: {self.pca.n_components_}")
    
    def detect_anomalies(self, df):
        """Detect anomalies in new sensor data"""
        if not self.is_fitted:
            raise ValueError("Model must be fitted before detecting anomalies")
        
        X = self.preprocess_data(df)
        
        # Scale and transform
        X_scaled = self.scaler.transform(X)
        X_pca = self.pca.transform(X_scaled)
        
        # Get anomaly predictions and scores
        anomaly_labels = self.isolation_forest.predict(X_pca)  # -1 for anomaly, 1 for normal
        anomaly_scores = self.isolation_forest.decision_function(X_pca)  # Lower scores = more anomalous
        
        # Convert to boolean flags (True = anomaly)
        is_anomaly = anomaly_labels == -1
        
        # Create results dataframe
        results = df.copy()
        results['anomaly_score'] = anomaly_scores
        results['is_anomaly'] = is_anomaly
        results['anomaly_severity'] = self._calculate_severity(anomaly_scores)
        
        return results
    
    def _calculate_severity(self, scores):
        """Calculate anomaly severity based on scores"""
        # Normalize scores to 0-1 scale (lower = more severe)
        min_score = scores.min()
        max_score = scores.max()
        normalized = (scores - min_score) / (max_score - min_score + 1e-6)
        
        # Invert so higher = more severe
        severity = 1 - normalized
        
        # Categorize severity
        severity_labels = []
        for s in severity:
            if s > 0.8:
                severity_labels.append('Critical')
            elif s > 0.6:
                severity_labels.append('High')
            elif s > 0.4:
                severity_labels.append('Medium')
            else:
                severity_labels.append('Low')
        
        return severity_labels
    
    def get_anomaly_summary(self, results):
        """Generate summary of detected anomalies"""
        anomalies = results[results['is_anomaly']]
        
        if len(anomalies) == 0:
            return "No anomalies detected"
        
        summary = {
            'total_anomalies': len(anomalies),
            'anomaly_rate': len(anomalies) / len(results),
            'severity_distribution': anomalies['anomaly_severity'].value_counts().to_dict(),
            'affected_parts': anomalies['part_id'].nunique(),
            'avg_anomaly_score': anomalies['anomaly_score'].mean()
        }
        
        return summary
    
    def save_model(self, model_path='models/anomaly_detector.pkl'):
        """Save trained anomaly detector"""
        model_data = {
            'isolation_forest': self.isolation_forest,
            'scaler': self.scaler,
            'pca': self.pca,
            'feature_columns': self.feature_columns,
            'is_fitted': self.is_fitted
        }
        joblib.dump(model_data, model_path)
        print(f"Anomaly detector saved to {model_path}")
    
    def load_model(self, model_path='models/anomaly_detector.pkl'):
        """Load trained anomaly detector"""
        model_data = joblib.load(model_path)
        self.isolation_forest = model_data['isolation_forest']
        self.scaler = model_data['scaler']
        self.pca = model_data['pca']
        self.feature_columns = model_data['feature_columns']
        self.is_fitted = model_data['is_fitted']
        print(f"Anomaly detector loaded from {model_path}")

def main():
    """Main anomaly detection pipeline"""
    # Initialize detector
    detector = AnomalyDetector(contamination=0.1)
    
    # Generate training data (normal operations)
    print("Generating training data...")
    normal_data = detector.generate_sensor_data(n_samples=3000, include_anomalies=False)
    
    # Fit detector on normal data
    print("Training anomaly detector...")
    detector.fit(normal_data)
    
    # Generate test data with anomalies
    print("Generating test data with anomalies...")
    test_data = detector.generate_sensor_data(n_samples=1000, include_anomalies=True)
    
    # Detect anomalies
    print("Detecting anomalies...")
    results = detector.detect_anomalies(test_data)
    
    # Print summary
    summary = detector.get_anomaly_summary(results)
    print("\nAnomaly Detection Summary:")
    if isinstance(summary, dict):
        for key, value in summary.items():
            print(f"{key}: {value}")
    else:
        print(summary)
    
    # Show sample anomalies
    anomalies = results[results['is_anomaly']].head()
    if len(anomalies) > 0:
        print("\nSample Anomalies:")
        print(anomalies[['part_id', 'temperature', 'vibration', 'anomaly_score', 'anomaly_severity']])
    
    # Save model
    detector.save_model()
    
    # Example: Real-time anomaly detection
    print("\nReal-time Anomaly Detection Example:")
    new_reading = pd.DataFrame([{
        'temperature': 110,  # Abnormally high
        'vibration': 5.5,    # High vibration
        'pressure': 145,
        'humidity': 42,
        'current': 25,       # High current
        'voltage': 20,       # Low voltage
        'rpm': 2300,         # High RPM
        'load': 0.95,
        'timestamp': pd.Timestamp.now(),
        'part_id': 'PART_TEST'
    }])
    
    result = detector.detect_anomalies(new_reading)
    print(f"Anomaly detected: {result['is_anomaly'].iloc[0]}")
    print(f"Severity: {result['anomaly_severity'].iloc[0]}")
    print(f"Score: {result['anomaly_score'].iloc[0]:.3f}")

if __name__ == "__main__":
    main()