const express = require('express');
const router = express.Router();
const { verifyToken, requireInspector } = require('../middleware/auth');
const mlService = require('../services/mlService');

// Train ML model (inspector only)
router.post('/train', verifyToken, requireInspector, async (req, res) => {
  try {
    const result = await mlService.trainModel();
    res.json(result);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Predict failure probability
router.post('/predict', verifyToken, async (req, res) => {
  try {
    const prediction = await mlService.predict(req.body);
    res.json(prediction);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get model status
router.get('/status', verifyToken, requireInspector, (req, res) => {
  res.json(mlService.getStatus());
});

module.exports = router;