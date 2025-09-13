"""
TensorFlow Deep Learning Model for Predictive Maintenance
Neural network approach for complex pattern recognition in sensor data
"""

import pandas as pd
import numpy as np
import tensorflow as tf
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Dense, Dropout, BatchNormalization
from tensorflow.keras.optimizers import Adam
from tensorflow.keras.callbacks import EarlyStopping
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
import joblib

class DeepMaintenanceModel:
    def __init__(self):
        self.model = None
        self.scaler = StandardScaler()
        self.feature_columns = None
        
    def create_model(self, input_dim):
        """Create neural network architecture"""
        model = Sequential([
            Dense(128, activation='relu', input_shape=(input_dim,)),
            BatchNormalization(),
            Dropout(0.3),
            
            Dense(64, activation='relu'),
            BatchNormalization(),
            Dropout(0.3),
            
            Dense(32, activation='relu'),
            Dropout(0.2),
            
            Dense(16, activation='relu'),
            Dense(1, activation='sigmoid')  # Binary classification
        ])
        
        model.compile(
            optimizer=Adam(learning_rate=0.001),
            loss='binary_crossentropy',
            metrics=['accuracy', 'precision', 'recall']
        )
        
        return model
    
    def prepare_data(self, n_samples=10000):
        """Generate synthetic time-series sensor data"""
        np.random.seed(42)
        
        # Create time-based features
        timestamps = pd.date_range('2023-01-01', periods=n_samples, freq='1H')
        
        data = {
            'timestamp': timestamps,
            'temperature': np.random.normal(75, 12, n_samples),
            'vibration': np.random.normal(2.2, 0.6, n_samples),
            'pressure': np.random.normal(150, 20, n_samples),
            'current': np.random.normal(12, 3, n_samples),
            'voltage': np.random.normal(24, 2, n_samples),
            'rpm': np.random.normal(1800, 150, n_samples),
            'load_factor': np.random.uniform(0.4, 1.0, n_samples),
            'operating_hours': np.cumsum(np.random.exponential(1, n_samples)),
        }
        
        df = pd.DataFrame(data)
        
        # Add time-based features
        df['hour'] = df['timestamp'].dt.hour
        df['day_of_week'] = df['timestamp'].dt.dayofweek
        df['month'] = df['timestamp'].dt.month
        
        # Rolling statistics (trend analysis)
        df['temp_rolling_mean'] = df['temperature'].rolling(window=24).mean()
        df['vibration_rolling_std'] = df['vibration'].rolling(window=12).std()
        df['pressure_trend'] = df['pressure'].rolling(window=48).apply(
            lambda x: np.polyfit(range(len(x)), x, 1)[0] if len(x) == 48 else 0
        )
        
        # Fill NaN values from rolling calculations
        df = df.fillna(method='bfill').fillna(0)
        
        # Create failure target with complex conditions
        failure_conditions = (
            (df['temperature'] > 90) & (df['vibration'] > 3.5) |
            (df['current'] > 18) & (df['voltage'] < 20) |
            (df['temp_rolling_mean'] > 85) & (df['vibration_rolling_std'] > 1.0) |
            (df['operating_hours'] > df['operating_hours'].quantile(0.9)) & 
            (df['load_factor'] > 0.9)
        )
        
        # Add some randomness
        random_failures = np.random.random(n_samples) < 0.05
        df['failure_risk'] = (failure_conditions | random_failures).astype(int)
        
        return df
    
    def train(self, df, epochs=50, batch_size=32):
        """Train the deep learning model"""
        # Feature selection
        self.feature_columns = [
            'temperature', 'vibration', 'pressure', 'current', 'voltage', 'rpm',
            'load_factor', 'operating_hours', 'hour', 'day_of_week', 'month',
            'temp_rolling_mean', 'vibration_rolling_std', 'pressure_trend'
        ]
        
        X = df[self.feature_columns]
        y = df['failure_risk']
        
        # Split data
        X_train, X_test, y_train, y_test = train_test_split(
            X, y, test_size=0.2, random_state=42, stratify=y
        )
        
        # Scale features
        X_train_scaled = self.scaler.fit_transform(X_train)
        X_test_scaled = self.scaler.transform(X_test)
        
        # Create model
        self.model = self.create_model(X_train_scaled.shape[1])
        
        # Early stopping
        early_stopping = EarlyStopping(
            monitor='val_loss',
            patience=10,
            restore_best_weights=True
        )
        
        # Train model
        history = self.model.fit(
            X_train_scaled, y_train,
            validation_data=(X_test_scaled, y_test),
            epochs=epochs,
            batch_size=batch_size,
            callbacks=[early_stopping],
            verbose=1
        )
        
        # Evaluate
        test_loss, test_acc, test_precision, test_recall = self.model.evaluate(
            X_test_scaled, y_test, verbose=0
        )
        
        print(f"\nTest Results:")
        print(f"Accuracy: {test_acc:.4f}")
        print(f"Precision: {test_precision:.4f}")
        print(f"Recall: {test_recall:.4f}")
        print(f"F1-Score: {2 * test_precision * test_recall / (test_precision + test_recall):.4f}")
        
        return history
    
    def predict(self, sensor_data):
        """Predict failure probability"""
        if isinstance(sensor_data, dict):
            df = pd.DataFrame([sensor_data])
        else:
            df = sensor_data.copy()
        
        # Ensure all required features are present
        for col in self.feature_columns:
            if col not in df.columns:
                df[col] = 0  # Default value for missing features
        
        X = df[self.feature_columns]
        X_scaled = self.scaler.transform(X)
        
        probabilities = self.model.predict(X_scaled, verbose=0)
        return probabilities.flatten()
    
    def save_model(self, model_path='models/deep_maintenance_model'):
        """Save TensorFlow model and scaler"""
        self.model.save(f"{model_path}.h5")
        joblib.dump({
            'scaler': self.scaler,
            'feature_columns': self.feature_columns
        }, f"{model_path}_scaler.pkl")
        print(f"Model saved to {model_path}")
    
    def load_model(self, model_path='models/deep_maintenance_model'):
        """Load TensorFlow model and scaler"""
        self.model = tf.keras.models.load_model(f"{model_path}.h5")
        scaler_data = joblib.load(f"{model_path}_scaler.pkl")
        self.scaler = scaler_data['scaler']
        self.feature_columns = scaler_data['feature_columns']
        print(f"Model loaded from {model_path}")

def main():
    """Main training pipeline for deep learning model"""
    # Initialize model
    deep_model = DeepMaintenanceModel()
    
    # Prepare data
    print("Preparing training data...")
    df = deep_model.prepare_data(n_samples=15000)
    
    print(f"Dataset shape: {df.shape}")
    print(f"Failure rate: {df['failure_risk'].mean():.2%}")
    
    # Train model
    print("\nTraining deep learning model...")
    history = deep_model.train(df, epochs=30, batch_size=64)
    
    # Save model
    deep_model.save_model()
    
    # Example prediction
    print("\nExample Prediction:")
    sample_data = {
        'temperature': 95,
        'vibration': 4.2,
        'pressure': 140,
        'current': 19,
        'voltage': 19,
        'rpm': 2100,
        'load_factor': 0.95,
        'operating_hours': 8000,
        'hour': 14,
        'day_of_week': 2,
        'month': 6,
        'temp_rolling_mean': 88,
        'vibration_rolling_std': 1.2,
        'pressure_trend': -0.5
    }
    
    probability = deep_model.predict(sample_data)
    print(f"Failure probability: {probability[0]:.2%}")
    print(f"Risk level: {'HIGH' if probability[0] > 0.7 else 'MEDIUM' if probability[0] > 0.3 else 'LOW'}")

if __name__ == "__main__":
    main()