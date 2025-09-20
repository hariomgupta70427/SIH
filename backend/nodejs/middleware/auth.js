const admin = require('firebase-admin');

const verifyToken = async (req, res, next) => {
  try {
    const token = req.headers.authorization?.split('Bearer ')[1];
    
    if (!token) {
      // For development, create mock user
      req.user = {
        uid: 'mock-user-id',
        email: 'mock@example.com',
        role: 'inspector',
        name: 'Mock User'
      };
      return next();
    }

    try {
      const decodedToken = await admin.auth().verifyIdToken(token);
      
      // Get user role from Firestore
      const userDoc = await admin.firestore()
        .collection('users')
        .doc(decodedToken.uid)
        .get();
      
      const userData = userDoc.data();
      req.user = {
        ...decodedToken,
        role: userData?.role || 'user',
        name: userData?.name
      };
    } catch (firebaseError) {
      // Fallback to mock user for development
      req.user = {
        uid: 'mock-user-id',
        email: 'mock@example.com',
        role: 'inspector',
        name: 'Mock User'
      };
    }
    
    next();
  } catch (error) {
    res.status(401).json({ error: 'Invalid token' });
  }
};

const requireInspector = async (req, res, next) => {
  try {
    const userDoc = await admin.firestore()
      .collection('users')
      .doc(req.user.uid)
      .get();
    
    const userData = userDoc.data();
    if (!userData || userData.role !== 'inspector') {
      return res.status(403).json({ error: 'Inspector access required' });
    }
    
    next();
  } catch (error) {
    res.status(500).json({ error: 'Role verification failed' });
  }
};

module.exports = { verifyToken, requireInspector };