// Create test users for development
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
  })
});

const db = admin.firestore();

async function createTestUsers() {
  try {
    // Create inspector user
    const inspectorUser = await admin.auth().createUser({
      email: 'inspector@qrail.com',
      password: 'inspector123',
      displayName: 'Test Inspector'
    });
    
    await db.collection('users').doc(inspectorUser.uid).set({
      email: 'inspector@qrail.com',
      role: 'inspector',
      name: 'Test Inspector',
      createdAt: admin.firestore.FieldValue.serverTimestamp()
    });
    
    // Create vendor user
    const vendorUser = await admin.auth().createUser({
      email: 'vendor@qrail.com',
      password: 'vendor123',
      displayName: 'Test Vendor'
    });
    
    await db.collection('users').doc(vendorUser.uid).set({
      email: 'vendor@qrail.com',
      role: 'vendor',
      name: 'Test Vendor',
      createdAt: admin.firestore.FieldValue.serverTimestamp()
    });
    
    // Create regular user
    const regularUser = await admin.auth().createUser({
      email: 'user@qrail.com',
      password: 'user123',
      displayName: 'Test User'
    });
    
    await db.collection('users').doc(regularUser.uid).set({
      email: 'user@qrail.com',
      role: 'user',
      name: 'Test User',
      createdAt: admin.firestore.FieldValue.serverTimestamp()
    });
    
    console.log('✅ Test users created successfully!');
    console.log('Inspector: inspector@qrail.com / inspector123');
    console.log('Vendor: vendor@qrail.com / vendor123');
    console.log('User: user@qrail.com / user123');
    
  } catch (error) {
    console.error('Error creating test users:', error);
  }
}

createTestUsers();