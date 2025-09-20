// Test script to simulate real-time data updates
require('dotenv').config();
const admin = require('firebase-admin');

// Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert({
    type: "service_account",
    project_id: process.env.FIREBASE_PROJECT_ID,
    private_key_id: process.env.FIREBASE_PRIVATE_KEY_ID,
    private_key: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n'),
    client_email: process.env.FIREBASE_CLIENT_EMAIL,
    client_id: process.env.FIREBASE_CLIENT_ID,
    auth_uri: process.env.FIREBASE_AUTH_URI,
    token_uri: process.env.FIREBASE_TOKEN_URI
  }),
  databaseURL: process.env.FIREBASE_DATABASE_URL,
  storageBucket: process.env.FIREBASE_STORAGE_BUCKET
});

const db = admin.firestore();

// Add test inspection data
async function addTestInspection() {
  const statuses = ['pending', 'completed', 'failed'];
  const partTypes = ['Wheel', 'Brake', 'Engine', 'Track', 'Signal'];
  
  const inspection = {
    partId: `P-${Math.floor(Math.random() * 1000).toString().padStart(3, '0')}`,
    partType: partTypes[Math.floor(Math.random() * partTypes.length)],
    status: statuses[Math.floor(Math.random() * statuses.length)],
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
    userId: 'test-user',
    location: 'Test Station'
  };
  
  await db.collection('inspections').add(inspection);
  console.log('Added test inspection:', inspection.partId);
}

// Add test data every 5 seconds
setInterval(addTestInspection, 5000);
console.log('Test script running - adding inspection data every 5 seconds');
console.log('Press Ctrl+C to stop');