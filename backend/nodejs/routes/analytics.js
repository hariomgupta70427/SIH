const express = require('express');
const router = express.Router();
const admin = require('firebase-admin');
const { verifyToken, requireInspector } = require('../middleware/auth');
const db = admin.firestore();

// Protected analytics endpoint
router.get('/', verifyToken, requireInspector, async (req, res) => {
  try {
    const snapshot = await db.collection('inspections').get();
    const inspections = snapshot.docs.map(doc => doc.data());
    
    const analytics = {
      total: inspections.length,
      pending: inspections.filter(i => i.status === 'pending').length,
      completed: inspections.filter(i => i.status === 'completed').length,
      failed: inspections.filter(i => i.status === 'failed').length,
      byDate: getInspectionsByDate(inspections),
      byType: getInspectionsByType(inspections),
      storageUsage: await getStorageUsage()
    };
    
    res.json(analytics);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

async function getStorageUsage() {
  try {
    const [files] = await admin.storage().bucket().getFiles();
    const totalSize = files.reduce((sum, file) => sum + parseInt(file.metadata.size || 0), 0);
    return {
      fileCount: files.length,
      totalSizeMB: Math.round(totalSize / (1024 * 1024))
    };
  } catch (error) {
    return { fileCount: 0, totalSizeMB: 0 };
  }
}

function getInspectionsByDate(inspections) {
  const dateMap = {};
  inspections.forEach(inspection => {
    const date = new Date(inspection.timestamp?.toDate?.() || inspection.timestamp).toDateString();
    dateMap[date] = (dateMap[date] || 0) + 1;
  });
  return dateMap;
}

function getInspectionsByType(inspections) {
  const typeMap = {};
  inspections.forEach(inspection => {
    const type = inspection.partType || 'Unknown';
    typeMap[type] = (typeMap[type] || 0) + 1;
  });
  return typeMap;
}

module.exports = router;