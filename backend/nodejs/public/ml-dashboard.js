// ML Dashboard JavaScript
let isTraining = false;

// Load page
document.addEventListener('DOMContentLoaded', () => {
    loadStatus();
});

// Load model status
async function loadStatus() {
    try {
        const response = await fetch('/api/ml/status');
        const status = await response.json();
        
        document.getElementById('modelStatus').textContent = status.modelLoaded ? 'Loaded' : 'Not Loaded';
        document.getElementById('trainingStatus').textContent = status.isTraining ? 'Training...' : 'Idle';
        
        const trainBtn = document.getElementById('trainBtn');
        trainBtn.disabled = status.isTraining;
        trainBtn.textContent = status.isTraining ? 'Training...' : 'Train Model';
        
        isTraining = status.isTraining;
        
        log(`Status updated: Model ${status.modelLoaded ? 'loaded' : 'not loaded'}`);
    } catch (error) {
        log(`Error loading status: ${error.message}`);
    }
}

// Train model
async function trainModel() {
    if (isTraining) return;
    
    isTraining = true;
    document.getElementById('trainBtn').disabled = true;
    document.getElementById('trainBtn').textContent = 'Training...';
    document.getElementById('trainingStatus').textContent = 'Training...';
    
    log('Starting model training...');
    
    try {
        const response = await fetch('/api/ml/train', { method: 'POST' });
        const result = await response.json();
        
        if (result.success) {
            log(`Training completed: ${result.message} (${result.samples} samples)`);
            document.getElementById('modelStatus').textContent = 'Loaded';
        } else {
            log(`Training failed: ${result.message}`);
        }
    } catch (error) {
        log(`Training error: ${error.message}`);
    } finally {
        isTraining = false;
        document.getElementById('trainBtn').disabled = false;
        document.getElementById('trainBtn').textContent = 'Train Model';
        document.getElementById('trainingStatus').textContent = 'Idle';
    }
}

// Make prediction
async function predict() {
    const condition = document.getElementById('condition').value;
    const priority = document.getElementById('priority').value;
    const defectCount = parseInt(document.getElementById('defectCount').value) || 0;
    const ageDays = parseInt(document.getElementById('ageDays').value) || 0;
    
    const defects = Array(defectCount).fill('Sample defect');
    const timestamp = new Date(Date.now() - ageDays * 24 * 60 * 60 * 1000).toISOString();
    
    try {
        const response = await fetch('/api/ml/predict', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                condition,
                priority,
                defects,
                timestamp
            })
        });
        
        const prediction = await response.json();
        displayPrediction(prediction);
        log(`Prediction: ${(prediction.failureProbability * 100).toFixed(1)}% failure risk (${prediction.riskLevel})`);
    } catch (error) {
        log(`Prediction error: ${error.message}`);
    }
}

// Display prediction result
function displayPrediction(prediction) {
    const resultDiv = document.getElementById('predictionResult');
    const probability = (prediction.failureProbability * 100).toFixed(1);
    const riskClass = `risk-${prediction.riskLevel}`;
    
    resultDiv.innerHTML = `
        <div class="prediction-result ${riskClass}">
            <strong>Failure Probability: ${probability}%</strong><br>
            Risk Level: ${prediction.riskLevel.toUpperCase()}<br>
            <small>Based on: condition=${prediction.features.condition}, age=${prediction.features.ageDays} days, defects=${prediction.features.defectCount}</small>
        </div>
    `;
}

// Log message
function log(message) {
    const logDiv = document.getElementById('log');
    const timestamp = new Date().toLocaleTimeString();
    logDiv.innerHTML += `[${timestamp}] ${message}\n`;
    logDiv.scrollTop = logDiv.scrollHeight;
}

// Auto-refresh status every 5 seconds during training
setInterval(() => {
    if (isTraining) {
        loadStatus();
    }
}, 5000);