require('dotenv').config();
const express = require('express');
const cors = require('cors');
const http = require('http');
const socketIo = require('socket.io');
const admin = require('firebase-admin');

const app = express();
const server = http.createServer(app);
const io = socketIo(server, {
  cors: { origin: "*", methods: ["GET", "POST"] }
});

// Firebase Admin initialization
try {
  const firebaseConfig = {
    credential: admin.credential.cert({
      type: "service_account",
      project_id: process.env.FIREBASE_PROJECT_ID || 'smartindiahackathon-a62a3',
      private_key_id: process.env.FIREBASE_PRIVATE_KEY_ID || 'dummy-key-id',
      private_key: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n') || '-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC7VJTUt9Us8cKB\n-----END PRIVATE KEY-----\n',
      client_email: process.env.FIREBASE_CLIENT_EMAIL || 'firebase-adminsdk-dummy@smartindiahackathon-a62a3.iam.gserviceaccount.com',
      client_id: process.env.FIREBASE_CLIENT_ID || 'dummy-client-id',
      auth_uri: process.env.FIREBASE_AUTH_URI || 'https://accounts.google.com/o/oauth2/auth',
      token_uri: process.env.FIREBASE_TOKEN_URI || 'https://oauth2.googleapis.com/token'
    }),
    databaseURL: process.env.FIREBASE_DATABASE_URL || 'https://smartindiahackathon-a62a3-default-rtdb.firebaseio.com',
    storageBucket: process.env.FIREBASE_STORAGE_BUCKET || 'smartindiahackathon-a62a3.firebasestorage.app'
  };

  // Use emulator in development
  if (process.env.FIRESTORE_EMULATOR_HOST) {
    console.log('Using Firebase Emulator Suite');
    process.env.FIREBASE_AUTH_EMULATOR_HOST = 'localhost:9099';
    process.env.FIREBASE_STORAGE_EMULATOR_HOST = 'localhost:9199';
  }

  admin.initializeApp(firebaseConfig);
  console.log('✅ Firebase Admin initialized successfully');
} catch (error) {
  console.log('⚠️ Firebase Admin initialization failed, using mock mode:', error.message);
}

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.static('public'));

// Routes
app.use('/api/auth', require('./routes/auth'));
app.use('/api/inspections', require('./routes/inspections'));
app.use('/api/analytics', require('./routes/analytics'));
app.use('/api/ml', require('./routes/ml'));
app.use('/api/parts', require('./routes/parts'));

// Dashboard route
app.get('/dashboard', (req, res) => {
  res.sendFile(__dirname + '/public/dashboard.html');
});

// Data entry route
app.get('/data-entry', (req, res) => {
  res.sendFile(__dirname + '/public/data-entry.html');
});

// Inspections management route
app.get('/inspections', (req, res) => {
  res.sendFile(__dirname + '/public/inspections.html');
});

// ML dashboard route
app.get('/ml-dashboard', (req, res) => {
  res.sendFile(__dirname + '/public/ml-dashboard.html');
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ 
    status: 'healthy', 
    timestamp: new Date().toISOString(),
    version: require('./package.json').version,
    node: process.version
  });
});

// Test endpoint
app.get('/test', (req, res) => {
  res.json({ message: 'Backend is working!', timestamp: new Date().toISOString() });
});

// Real-time analytics
require('./services/analyticsService').startRealTimeUpdates(io);

// Start cleanup service
require('./services/cleanupService').startPeriodicCleanup();

// Initialize ML service
require('./services/mlService').loadModel();

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
  console.log(`Dashboard: http://localhost:${PORT}`);
});

module.exports = { app, io };