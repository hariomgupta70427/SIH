// Simple test to verify backend functionality
const http = require('http');

// Test health endpoint
const options = {
  hostname: 'localhost',
  port: 3000,
  path: '/health',
  method: 'GET'
};

const req = http.request(options, (res) => {
  console.log(`Status: ${res.statusCode}`);
  
  let data = '';
  res.on('data', (chunk) => {
    data += chunk;
  });
  
  res.on('end', () => {
    console.log('Response:', JSON.parse(data));
    console.log('✅ Backend is working!');
  });
});

req.on('error', (e) => {
  console.error('❌ Backend connection failed:', e.message);
  console.log('Make sure to start the backend server first:');
  console.log('cd backend/nodejs && npm start');
});

req.end();