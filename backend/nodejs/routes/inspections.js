const express = require('express');
const router = express.Router();
const admin = require('firebase-admin');
const { verifyToken, requireInspector } = require('../middleware/auth');
const storageService = require('../services/storageService');
const mlService = require('../services/mlService');
const multer = require('multer');
const db = admin.firestore();

const upload = multer({ storage: multer.memoryStorage() });

// Get inspections (protected route)
router.get('/', verifyToken, async (req, res) => {
  try {
    const snapshot = await db.collection('inspections').get();
    const inspections = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));
    res.json(inspections);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Add detailed inspection with file upload
router.post('/', verifyToken, upload.single('image'), async (req, res) => {
  try {
    let imageUrl = null;
    
    if (req.file) {
      const fileName = `inspections/${Date.now()}_${req.file.originalname}`;
      imageUrl = await storageService.uploadFile(req.file, fileName);
    }
    
    const {
      partId,
      partType,
      partName,
      location,
      measurements,
      condition,
      defects,
      notes,
      priority
    } = req.body;
    
    const inspection = {
      partId,
      partType,
      partName,
      location,
      measurements: measurements ? JSON.parse(measurements) : {},
      condition,
      defects: defects ? JSON.parse(defects) : [],
      notes,
      priority: priority || 'medium',
      imageUrl,
      inspectorId: req.user.uid,
      inspectorName: req.user.name || req.user.email,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      status: 'pending',
      ttl: new Date(Date.now() + 90 * 24 * 60 * 60 * 1000)
    };
    
    const docRef = await db.collection('inspections').add(inspection);
    
    // Run ML prediction asynchronously
    try {
      const prediction = await mlService.predict(inspection);
      await docRef.update({ mlPrediction: prediction });
    } catch (mlError) {
      console.log('ML prediction failed:', mlError.message);
    }
    
    res.json({ id: docRef.id, ...inspection });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Update inspection status (inspector only)
router.patch('/:id', verifyToken, requireInspector, async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body;
    
    await db.collection('inspections').doc(id).update({ 
      status,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedBy: req.user.uid
    });
    
    res.json({ success: true });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Delete old inspections (cleanup)
router.delete('/cleanup', verifyToken, requireInspector, async (req, res) => {
  try {
    const cutoffDate = new Date(Date.now() - 90 * 24 * 60 * 60 * 1000);
    const snapshot = await db.collection('inspections')
      .where('timestamp', '<', cutoffDate)
      .get();
    
    const batch = db.batch();
    snapshot.docs.forEach(doc => {
      batch.delete(doc.ref);
    });
    
    await batch.commit();
    await storageService.cleanupOldFiles(90);
    
    res.json({ deleted: snapshot.size });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;