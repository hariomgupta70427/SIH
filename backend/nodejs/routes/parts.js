const express = require('express');
const admin = require('firebase-admin');
const router = express.Router();

const db = admin.firestore();

// Get part by ID
router.get('/:partId', async (req, res) => {
  try {
    const { partId } = req.params;
    
    const partDoc = await db.collection('parts').doc(partId).get();
    
    if (!partDoc.exists) {
      return res.status(404).json({ error: 'Part not found' });
    }
    
    const partData = partDoc.data();
    
    res.json({
      id: partDoc.id,
      ...partData,
      manufacturingDate: partData.manufacturingDate?.toDate?.()?.toISOString() || partData.manufacturingDate,
      createdAt: partData.createdAt?.toDate?.()?.toISOString() || partData.createdAt,
    });
  } catch (error) {
    console.error('Error fetching part:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Create new part
router.post('/', async (req, res) => {
  try {
    const {
      partName,
      vendorName,
      vendorId,
      batchNo,
      warrantyPeriod,
      inspectionInterval,
      manufacturingDate,
      description,
      specifications
    } = req.body;
    
    // Validate required fields
    if (!partName || !vendorName || !vendorId || !batchNo || !warrantyPeriod || !inspectionInterval || !manufacturingDate) {
      return res.status(400).json({ error: 'Missing required fields' });
    }
    
    const partData = {
      partName,
      vendorName,
      vendorId,
      batchNo,
      warrantyPeriod: parseInt(warrantyPeriod),
      inspectionInterval: parseInt(inspectionInterval),
      manufacturingDate: admin.firestore.Timestamp.fromDate(new Date(manufacturingDate)),
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      status: 'active',
      description: description || null,
      specifications: specifications || null,
    };
    
    const docRef = await db.collection('parts').add(partData);
    
    res.status(201).json({
      id: docRef.id,
      message: 'Part created successfully',
    });
  } catch (error) {
    console.error('Error creating part:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get parts by vendor
router.get('/vendor/:vendorId', async (req, res) => {
  try {
    const { vendorId } = req.params;
    const { status, limit = 50 } = req.query;
    
    let query = db.collection('parts')
      .where('vendorId', '==', vendorId)
      .orderBy('createdAt', 'desc')
      .limit(parseInt(limit));
    
    if (status) {
      query = query.where('status', '==', status);
    }
    
    const snapshot = await query.get();
    
    const parts = [];
    snapshot.forEach(doc => {
      const data = doc.data();
      parts.push({
        id: doc.id,
        ...data,
        manufacturingDate: data.manufacturingDate?.toDate?.()?.toISOString() || data.manufacturingDate,
        createdAt: data.createdAt?.toDate?.()?.toISOString() || data.createdAt,
      });
    });
    
    res.json(parts);
  } catch (error) {
    console.error('Error fetching vendor parts:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Update part status
router.patch('/:partId/status', async (req, res) => {
  try {
    const { partId } = req.params;
    const { status } = req.body;
    
    if (!status) {
      return res.status(400).json({ error: 'Status is required' });
    }
    
    await db.collection('parts').doc(partId).update({
      status,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    
    res.json({ message: 'Part status updated successfully' });
  } catch (error) {
    console.error('Error updating part status:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get scan history for inspector
router.get('/scans/inspector/:inspectorId', async (req, res) => {
  try {
    const { inspectorId } = req.params;
    const { limit = 50 } = req.query;
    
    const snapshot = await db.collection('scan_history')
      .where('inspectorId', '==', inspectorId)
      .orderBy('scannedAt', 'desc')
      .limit(parseInt(limit))
      .get();
    
    const scans = [];
    snapshot.forEach(doc => {
      const data = doc.data();
      scans.push({
        id: doc.id,
        ...data,
        scannedAt: data.scannedAt?.toDate?.()?.toISOString() || data.scannedAt,
      });
    });
    
    res.json(scans);
  } catch (error) {
    console.error('Error fetching scan history:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Add scan history
router.post('/scans', async (req, res) => {
  try {
    const {
      inspectorId,
      partId,
      partName,
      vendorName,
      status = 'scanned',
      remarks,
      inspectionResult,
      inspectionData
    } = req.body;
    
    if (!inspectorId || !partId || !partName || !vendorName) {
      return res.status(400).json({ error: 'Missing required fields' });
    }
    
    const scanData = {
      inspectorId,
      partId,
      partName,
      vendorName,
      scannedAt: admin.firestore.FieldValue.serverTimestamp(),
      status,
      remarks: remarks || null,
      inspectionResult: inspectionResult || null,
      inspectionData: inspectionData || null,
    };
    
    const docRef = await db.collection('scan_history').add(scanData);
    
    res.status(201).json({
      id: docRef.id,
      message: 'Scan history added successfully',
    });
  } catch (error) {
    console.error('Error adding scan history:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Update scan history
router.patch('/scans/:scanId', async (req, res) => {
  try {
    const { scanId } = req.params;
    const updates = req.body;
    
    // Add timestamp for updates
    updates.updatedAt = admin.firestore.FieldValue.serverTimestamp();
    
    await db.collection('scan_history').doc(scanId).update(updates);
    
    res.json({ message: 'Scan history updated successfully' });
  } catch (error) {
    console.error('Error updating scan history:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get analytics data
router.get('/analytics/summary', async (req, res) => {
  try {
    const { vendorId, inspectorId, days = 30 } = req.query;
    
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - parseInt(days));
    
    let partsQuery = db.collection('parts');
    let scansQuery = db.collection('scan_history');
    
    if (vendorId) {
      partsQuery = partsQuery.where('vendorId', '==', vendorId);
    }
    
    if (inspectorId) {
      scansQuery = scansQuery.where('inspectorId', '==', inspectorId);
    }
    
    // Add date filter
    scansQuery = scansQuery.where('scannedAt', '>=', admin.firestore.Timestamp.fromDate(startDate));
    
    const [partsSnapshot, scansSnapshot] = await Promise.all([
      partsQuery.get(),
      scansQuery.get()
    ]);
    
    const totalParts = partsSnapshot.size;
    const totalScans = scansSnapshot.size;
    
    let passedInspections = 0;
    let failedInspections = 0;
    
    scansSnapshot.forEach(doc => {
      const data = doc.data();
      if (data.inspectionResult === 'pass') {
        passedInspections++;
      } else if (data.inspectionResult === 'fail') {
        failedInspections++;
      }
    });
    
    res.json({
      totalParts,
      totalScans,
      passedInspections,
      failedInspections,
      inspectionRate: totalScans > 0 ? ((passedInspections + failedInspections) / totalScans * 100).toFixed(1) : 0,
      passRate: (passedInspections + failedInspections) > 0 ? (passedInspections / (passedInspections + failedInspections) * 100).toFixed(1) : 0,
    });
  } catch (error) {
    console.error('Error fetching analytics:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;