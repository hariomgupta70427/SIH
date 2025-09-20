const express = require('express');
const router = express.Router();
const admin = require('firebase-admin');
const { verifyToken } = require('../middleware/auth');
const db = admin.firestore();

// Create user profile after registration
router.post('/profile', verifyToken, async (req, res) => {
  try {
    const { role = 'user', department, name } = req.body;
    
    const userProfile = {
      uid: req.user.uid,
      email: req.user.email,
      name: name || req.user.name,
      role,
      department,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      lastLogin: admin.firestore.FieldValue.serverTimestamp()
    };
    
    await db.collection('users').doc(req.user.uid).set(userProfile, { merge: true });
    res.json({ success: true, profile: userProfile });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get user profile
router.get('/profile', verifyToken, async (req, res) => {
  try {
    const userDoc = await db.collection('users').doc(req.user.uid).get();
    
    if (!userDoc.exists) {
      return res.status(404).json({ error: 'Profile not found' });
    }
    
    // Update last login
    await db.collection('users').doc(req.user.uid).update({
      lastLogin: admin.firestore.FieldValue.serverTimestamp()
    });
    
    res.json(userDoc.data());
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Verify token endpoint
router.post('/verify', verifyToken, (req, res) => {
  res.json({ 
    valid: true, 
    user: {
      uid: req.user.uid,
      email: req.user.email,
      name: req.user.name
    }
  });
});

module.exports = router;