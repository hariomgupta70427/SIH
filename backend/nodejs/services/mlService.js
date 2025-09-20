const tf = require('@tensorflow/tfjs-node');
const admin = require('firebase-admin');
const db = admin.firestore();

class MLService {
  constructor() {
    this.model = null;
    this.isTraining = false;
    this.features = ['condition_score', 'age_days', 'defect_count', 'priority_score'];
  }

  // Convert condition to numeric score
  conditionToScore(condition) {
    const scores = { 'excellent': 5, 'good': 4, 'fair': 3, 'poor': 2, 'critical': 1 };
    return scores[condition] || 3;
  }

  // Convert priority to numeric score
  priorityToScore(priority) {
    const scores = { 'low': 1, 'medium': 2, 'high': 3, 'urgent': 4 };
    return scores[priority] || 2;
  }

  // Prepare training data from inspections
  async prepareTrainingData() {
    const snapshot = await db.collection('inspections').get();
    const data = [];
    
    snapshot.docs.forEach(doc => {
      const inspection = doc.data();
      if (!inspection.timestamp || !inspection.condition) return;
      
      const ageDays = Math.floor((Date.now() - inspection.timestamp.toDate()) / (1000 * 60 * 60 * 24));
      const conditionScore = this.conditionToScore(inspection.condition);
      const defectCount = Array.isArray(inspection.defects) ? inspection.defects.length : 0;
      const priorityScore = this.priorityToScore(inspection.priority);
      
      // Label: 1 if failed, 0 if completed/good condition
      const label = inspection.status === 'failed' || conditionScore <= 2 ? 1 : 0;
      
      data.push({
        features: [conditionScore, ageDays, defectCount, priorityScore],
        label: label
      });
    });
    
    return data;
  }

  // Train the model
  async trainModel() {
    if (this.isTraining) return { success: false, message: 'Training already in progress' };
    
    this.isTraining = true;
    console.log('Starting ML model training...');
    
    try {
      const data = await this.prepareTrainingData();
      if (data.length < 10) {
        throw new Error('Insufficient training data (minimum 10 samples required)');
      }
      
      // Prepare tensors
      const features = tf.tensor2d(data.map(d => d.features));
      const labels = tf.tensor2d(data.map(d => [d.label]));
      
      // Create model
      this.model = tf.sequential({
        layers: [
          tf.layers.dense({ inputShape: [4], units: 8, activation: 'relu' }),
          tf.layers.dense({ units: 4, activation: 'relu' }),
          tf.layers.dense({ units: 1, activation: 'sigmoid' })
        ]
      });
      
      this.model.compile({
        optimizer: 'adam',
        loss: 'binaryCrossentropy',
        metrics: ['accuracy']
      });
      
      // Train model
      await this.model.fit(features, labels, {
        epochs: 50,
        batchSize: 8,
        validationSplit: 0.2,
        verbose: 0
      });
      
      // Save model
      await this.model.save('file://./models/failure-prediction');
      
      features.dispose();
      labels.dispose();
      
      console.log('Model training completed');
      return { success: true, message: 'Model trained successfully', samples: data.length };
      
    } catch (error) {
      console.error('Training error:', error);
      return { success: false, message: error.message };
    } finally {
      this.isTraining = false;
    }
  }

  // Load existing model
  async loadModel() {
    try {
      this.model = await tf.loadLayersModel('file://./models/failure-prediction/model.json');
      console.log('Model loaded successfully');
      return true;
    } catch (error) {
      console.log('No existing model found, will need to train first');
      return false;
    }
  }

  // Predict failure probability
  async predict(inspection) {
    if (!this.model) {
      await this.loadModel();
      if (!this.model) {
        throw new Error('Model not available. Please train the model first.');
      }
    }
    
    const ageDays = inspection.timestamp 
      ? Math.floor((Date.now() - new Date(inspection.timestamp)) / (1000 * 60 * 60 * 24))
      : 0;
    
    const features = [
      this.conditionToScore(inspection.condition),
      ageDays,
      Array.isArray(inspection.defects) ? inspection.defects.length : 0,
      this.priorityToScore(inspection.priority)
    ];
    
    const prediction = this.model.predict(tf.tensor2d([features]));
    const probability = await prediction.data();
    prediction.dispose();
    
    return {
      failureProbability: probability[0],
      riskLevel: probability[0] > 0.7 ? 'high' : probability[0] > 0.4 ? 'medium' : 'low',
      features: {
        condition: inspection.condition,
        ageDays,
        defectCount: Array.isArray(inspection.defects) ? inspection.defects.length : 0,
        priority: inspection.priority
      }
    };
  }

  // Get model status
  getStatus() {
    return {
      modelLoaded: !!this.model,
      isTraining: this.isTraining,
      features: this.features
    };
  }
}

module.exports = new MLService();