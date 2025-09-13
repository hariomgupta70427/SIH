// API endpoint testing script for integration validation
const axios = require('axios');

const API_BASE_URL = process.env.API_BASE_URL || 'http://localhost:3000/api';

// Test configuration
const testConfig = {
  timeout: 30000,
  headers: {
    'Content-Type': 'application/json'
  }
};

// Test data for API calls
const testPart = {
  name: 'Test Brake Assembly',
  part_number: 'TEST-2024-001',
  description: 'Test part for API validation',
  category: 'brake_system',
  status: 'active',
  quantity: 10,
  unit_price: 1000.00,
  location: 'Test-Warehouse',
  vendor_id: '550e8400-e29b-41d4-a716-446655440001'
};

const testInspection = {
  part_id: '650e8400-e29b-41d4-a716-446655440001',
  inspector_name: 'Test Inspector',
  inspection_type: 'routine',
  result: 'passed',
  score: 85,
  remarks: 'Test inspection for API validation'
};

// API test functions
async function testGetParts() {
  try {
    console.log('Testing GET /api/parts...');
    const response = await axios.get(`${API_BASE_URL}/parts`, testConfig);
    
    if (response.status === 200 && Array.isArray(response.data)) {
      console.log(`✓ GET /api/parts - Success (${response.data.length} parts)`);
      return true;
    } else {
      console.log('✗ GET /api/parts - Invalid response format');
      return false;
    }
  } catch (error) {
    console.log(`✗ GET /api/parts - Error: ${error.message}`);
    return false;
  }
}

async function testGetPartById() {
  try {
    console.log('Testing GET /api/parts/:id...');
    const response = await axios.get(`${API_BASE_URL}/parts/650e8400-e29b-41d4-a716-446655440001`, testConfig);
    
    if (response.status === 200 && response.data.name) {
      console.log(`✓ GET /api/parts/:id - Success (${response.data.name})`);
      return true;
    } else {
      console.log('✗ GET /api/parts/:id - Invalid response');
      return false;
    }
  } catch (error) {
    console.log(`✗ GET /api/parts/:id - Error: ${error.message}`);
    return false;
  }
}

async function testCreatePart() {
  try {
    console.log('Testing POST /api/parts...');
    const response = await axios.post(`${API_BASE_URL}/parts`, testPart, testConfig);
    
    if (response.status === 201 && response.data.id) {
      console.log(`✓ POST /api/parts - Success (ID: ${response.data.id})`);
      return response.data.id;
    } else {
      console.log('✗ POST /api/parts - Invalid response');
      return null;
    }
  } catch (error) {
    console.log(`✗ POST /api/parts - Error: ${error.message}`);
    return null;
  }
}

async function testUpdatePart(partId) {
  try {
    console.log('Testing PUT /api/parts/:id...');
    const updateData = { ...testPart, quantity: 15 };
    const response = await axios.put(`${API_BASE_URL}/parts/${partId}`, updateData, testConfig);
    
    if (response.status === 200 && response.data.quantity === 15) {
      console.log(`✓ PUT /api/parts/:id - Success (Updated quantity: ${response.data.quantity})`);
      return true;
    } else {
      console.log('✗ PUT /api/parts/:id - Update failed');
      return false;
    }
  } catch (error) {
    console.log(`✗ PUT /api/parts/:id - Error: ${error.message}`);
    return false;
  }
}

async function testGetInspections() {
  try {
    console.log('Testing GET /api/inspections...');
    const response = await axios.get(`${API_BASE_URL}/inspections`, testConfig);
    
    if (response.status === 200 && Array.isArray(response.data)) {
      console.log(`✓ GET /api/inspections - Success (${response.data.length} inspections)`);
      return true;
    } else {
      console.log('✗ GET /api/inspections - Invalid response format');
      return false;
    }
  } catch (error) {
    console.log(`✗ GET /api/inspections - Error: ${error.message}`);
    return false;
  }
}

async function testCreateInspection() {
  try {
    console.log('Testing POST /api/inspections...');
    const response = await axios.post(`${API_BASE_URL}/inspections`, testInspection, testConfig);
    
    if (response.status === 201 && response.data.id) {
      console.log(`✓ POST /api/inspections - Success (ID: ${response.data.id})`);
      return response.data.id;
    } else {
      console.log('✗ POST /api/inspections - Invalid response');
      return null;
    }
  } catch (error) {
    console.log(`✗ POST /api/inspections - Error: ${error.message}`);
    return null;
  }
}

async function testGetVendors() {
  try {
    console.log('Testing GET /api/vendors...');
    const response = await axios.get(`${API_BASE_URL}/vendors`, testConfig);
    
    if (response.status === 200 && Array.isArray(response.data)) {
      console.log(`✓ GET /api/vendors - Success (${response.data.length} vendors)`);
      return true;
    } else {
      console.log('✗ GET /api/vendors - Invalid response format');
      return false;
    }
  } catch (error) {
    console.log(`✗ GET /api/vendors - Error: ${error.message}`);
    return false;
  }
}

async function testQRCodeLookup() {
  try {
    console.log('Testing QR code lookup...');
    const response = await axios.get(`${API_BASE_URL}/parts?qr_code=QR001`, testConfig);
    
    if (response.status === 200 && response.data.length > 0) {
      console.log(`✓ QR code lookup - Success (Found: ${response.data[0].name})`);
      return true;
    } else {
      console.log('✗ QR code lookup - No results found');
      return false;
    }
  } catch (error) {
    console.log(`✗ QR code lookup - Error: ${error.message}`);
    return false;
  }
}

// Main test runner
async function runAPITests() {
  console.log('🚀 Starting API endpoint tests...\n');
  
  const results = {
    passed: 0,
    failed: 0,
    total: 0
  };
  
  const tests = [
    { name: 'Get Parts', fn: testGetParts },
    { name: 'Get Part by ID', fn: testGetPartById },
    { name: 'Get Vendors', fn: testGetVendors },
    { name: 'Get Inspections', fn: testGetInspections },
    { name: 'QR Code Lookup', fn: testQRCodeLookup },
    { name: 'Create Inspection', fn: testCreateInspection }
  ];
  
  // Run basic tests
  for (const test of tests) {
    results.total++;
    const success = await test.fn();
    if (success) {
      results.passed++;
    } else {
      results.failed++;
    }
    console.log(''); // Add spacing
  }
  
  // Test CRUD operations
  console.log('Testing CRUD operations...');
  results.total++;
  const createdPartId = await testCreatePart();
  if (createdPartId) {
    results.passed++;
    
    results.total++;
    const updateSuccess = await testUpdatePart(createdPartId);
    if (updateSuccess) {
      results.passed++;
    } else {
      results.failed++;
    }
  } else {
    results.failed++;
  }
  
  // Print summary
  console.log('\n📊 Test Results Summary:');
  console.log(`✅ Passed: ${results.passed}/${results.total}`);
  console.log(`❌ Failed: ${results.failed}/${results.total}`);
  console.log(`📈 Success Rate: ${((results.passed / results.total) * 100).toFixed(1)}%`);
  
  if (results.failed === 0) {
    console.log('\n🎉 All API tests passed!');
    return true;
  } else {
    console.log('\n⚠️  Some API tests failed. Check the logs above.');
    return false;
  }
}

// Export for use in other scripts
module.exports = { runAPITests };

// Run tests if called directly
if (require.main === module) {
  runAPITests()
    .then((success) => process.exit(success ? 0 : 1))
    .catch((error) => {
      console.error('Test runner error:', error);
      process.exit(1);
    });
}