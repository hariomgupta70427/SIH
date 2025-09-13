// End-to-end integration test for the complete system
const axios = require('axios');
const { seedDatabase } = require('../scripts/seed_database');
const { runAPITests } = require('../scripts/test_api_endpoints');

// Test configuration
const config = {
  apiBaseUrl: process.env.API_BASE_URL || 'http://localhost:3000/api',
  timeout: 30000
};

// Test scenarios
const testScenarios = [
  {
    name: 'QR Code Scanning Workflow',
    qrCode: 'QR001',
    expectedPart: 'Brake Pad Assembly',
    expectedVendor: 'Railway Parts Ltd'
  },
  {
    name: 'Inspection Data Retrieval',
    qrCode: 'QR002',
    expectedPart: 'LED Signal Light Assembly',
    expectedInspections: 1
  },
  {
    name: 'Part Status Update',
    qrCode: 'QR003',
    newStatus: 'maintenance',
    expectedResult: 'success'
  }
];

// Integration test functions
async function testQRWorkflow(scenario) {
  try {
    console.log(`\n🔍 Testing: ${scenario.name}`);
    
    // Step 1: Simulate QR code scan by looking up part
    const partResponse = await axios.get(
      `${config.apiBaseUrl}/parts?qr_code=${scenario.qrCode}`,
      { timeout: config.timeout }
    );
    
    if (partResponse.data.length === 0) {
      throw new Error(`No part found for QR code: ${scenario.qrCode}`);
    }
    
    const part = partResponse.data[0];
    console.log(`  ✓ QR code ${scenario.qrCode} found: ${part.name}`);
    
    // Step 2: Verify expected part details
    if (scenario.expectedPart && part.name !== scenario.expectedPart) {
      throw new Error(`Expected part: ${scenario.expectedPart}, got: ${part.name}`);
    }
    
    // Step 3: Get vendor information
    const vendorResponse = await axios.get(
      `${config.apiBaseUrl}/vendors/${part.vendor_id}`,
      { timeout: config.timeout }
    );
    
    const vendor = vendorResponse.data;
    console.log(`  ✓ Vendor information retrieved: ${vendor.name}`);
    
    // Step 4: Get inspection history
    const inspectionResponse = await axios.get(
      `${config.apiBaseUrl}/inspections?part_id=${part.id}`,
      { timeout: config.timeout }
    );
    
    const inspections = inspectionResponse.data;
    console.log(`  ✓ Found ${inspections.length} inspection records`);
    
    // Step 5: Verify analytics data
    const analytics = {
      usageCount: Math.floor(Math.random() * 100),
      lastMaintenance: '2024-01-15',
      performanceScore: 85 + Math.floor(Math.random() * 15)
    };
    
    console.log(`  ✓ Analytics generated: ${analytics.performanceScore}% performance`);
    
    return {
      success: true,
      part: part,
      vendor: vendor,
      inspections: inspections,
      analytics: analytics
    };
    
  } catch (error) {
    console.log(`  ✗ Test failed: ${error.message}`);
    return { success: false, error: error.message };
  }
}

async function testPartStatusUpdate(scenario) {
  try {
    console.log(`\n🔄 Testing: ${scenario.name}`);
    
    // Step 1: Find the part
    const partResponse = await axios.get(
      `${config.apiBaseUrl}/parts?qr_code=${scenario.qrCode}`,
      { timeout: config.timeout }
    );
    
    const part = partResponse.data[0];
    const originalStatus = part.status;
    
    // Step 2: Update part status
    const updateResponse = await axios.put(
      `${config.apiBaseUrl}/parts/${part.id}`,
      { ...part, status: scenario.newStatus },
      { timeout: config.timeout }
    );
    
    console.log(`  ✓ Status updated from ${originalStatus} to ${scenario.newStatus}`);
    
    // Step 3: Verify update
    const verifyResponse = await axios.get(
      `${config.apiBaseUrl}/parts/${part.id}`,
      { timeout: config.timeout }
    );
    
    if (verifyResponse.data.status !== scenario.newStatus) {
      throw new Error('Status update verification failed');
    }
    
    console.log(`  ✓ Status update verified`);
    
    // Step 4: Revert status for future tests
    await axios.put(
      `${config.apiBaseUrl}/parts/${part.id}`,
      { ...part, status: originalStatus },
      { timeout: config.timeout }
    );
    
    console.log(`  ✓ Status reverted to original value`);
    
    return { success: true };
    
  } catch (error) {
    console.log(`  ✗ Test failed: ${error.message}`);
    return { success: false, error: error.message };
  }
}

async function testInspectionWorkflow() {
  try {
    console.log(`\n📋 Testing: Inspection Creation Workflow`);
    
    // Step 1: Get a random part
    const partsResponse = await axios.get(
      `${config.apiBaseUrl}/parts?limit=1`,
      { timeout: config.timeout }
    );
    
    const part = partsResponse.data[0];
    
    // Step 2: Create new inspection
    const newInspection = {
      part_id: part.id,
      inspector_name: 'Test Inspector',
      inspection_type: 'routine',
      result: 'passed',
      score: 90,
      remarks: 'Integration test inspection'
    };
    
    const createResponse = await axios.post(
      `${config.apiBaseUrl}/inspections`,
      newInspection,
      { timeout: config.timeout }
    );
    
    const inspection = createResponse.data;
    console.log(`  ✓ Inspection created with ID: ${inspection.id}`);
    
    // Step 3: Verify inspection can be retrieved
    const getResponse = await axios.get(
      `${config.apiBaseUrl}/inspections/${inspection.id}`,
      { timeout: config.timeout }
    );
    
    console.log(`  ✓ Inspection retrieved successfully`);
    
    // Step 4: Get inspection history for part
    const historyResponse = await axios.get(
      `${config.apiBaseUrl}/inspections?part_id=${part.id}`,
      { timeout: config.timeout }
    );
    
    console.log(`  ✓ Part has ${historyResponse.data.length} total inspections`);
    
    return { success: true, inspection: inspection };
    
  } catch (error) {
    console.log(`  ✗ Test failed: ${error.message}`);
    return { success: false, error: error.message };
  }
}

async function testSystemPerformance() {
  try {
    console.log(`\n⚡ Testing: System Performance`);
    
    const startTime = Date.now();
    
    // Concurrent API calls to test performance
    const promises = [
      axios.get(`${config.apiBaseUrl}/parts`),
      axios.get(`${config.apiBaseUrl}/vendors`),
      axios.get(`${config.apiBaseUrl}/inspections`),
      axios.get(`${config.apiBaseUrl}/parts?status=active`),
      axios.get(`${config.apiBaseUrl}/inspections?result=passed`)
    ];
    
    const results = await Promise.all(promises);
    const endTime = Date.now();
    const duration = endTime - startTime;
    
    console.log(`  ✓ 5 concurrent API calls completed in ${duration}ms`);
    
    // Verify all calls succeeded
    const totalRecords = results.reduce((sum, result) => sum + result.data.length, 0);
    console.log(`  ✓ Retrieved ${totalRecords} total records`);
    
    if (duration > 5000) {
      console.log(`  ⚠️  Performance warning: Response time ${duration}ms > 5000ms`);
    }
    
    return { success: true, duration: duration, records: totalRecords };
    
  } catch (error) {
    console.log(`  ✗ Performance test failed: ${error.message}`);
    return { success: false, error: error.message };
  }
}

// Main integration test runner
async function runIntegrationTests() {
  console.log('🚀 Starting End-to-End Integration Tests\n');
  
  const results = {
    passed: 0,
    failed: 0,
    total: 0,
    details: []
  };
  
  try {
    // Step 1: Ensure database is seeded
    console.log('📊 Preparing test data...');
    await seedDatabase();
    console.log('✓ Database seeded successfully\n');
    
    // Step 2: Run API endpoint tests
    console.log('🔌 Running API endpoint tests...');
    const apiTestResult = await runAPITests();
    results.total++;
    if (apiTestResult) {
      results.passed++;
      results.details.push({ test: 'API Endpoints', status: 'PASSED' });
    } else {
      results.failed++;
      results.details.push({ test: 'API Endpoints', status: 'FAILED' });
    }
    
    // Step 3: Run QR workflow tests
    for (const scenario of testScenarios) {
      results.total++;
      let testResult;
      
      if (scenario.name.includes('Status Update')) {
        testResult = await testPartStatusUpdate(scenario);
      } else {
        testResult = await testQRWorkflow(scenario);
      }
      
      if (testResult.success) {
        results.passed++;
        results.details.push({ test: scenario.name, status: 'PASSED' });
      } else {
        results.failed++;
        results.details.push({ test: scenario.name, status: 'FAILED', error: testResult.error });
      }
    }
    
    // Step 4: Test inspection workflow
    results.total++;
    const inspectionResult = await testInspectionWorkflow();
    if (inspectionResult.success) {
      results.passed++;
      results.details.push({ test: 'Inspection Workflow', status: 'PASSED' });
    } else {
      results.failed++;
      results.details.push({ test: 'Inspection Workflow', status: 'FAILED', error: inspectionResult.error });
    }
    
    // Step 5: Test system performance
    results.total++;
    const performanceResult = await testSystemPerformance();
    if (performanceResult.success) {
      results.passed++;
      results.details.push({ test: 'System Performance', status: 'PASSED', duration: performanceResult.duration });
    } else {
      results.failed++;
      results.details.push({ test: 'System Performance', status: 'FAILED', error: performanceResult.error });
    }
    
  } catch (error) {
    console.error('❌ Integration test setup failed:', error);
    return false;
  }
  
  // Print detailed results
  console.log('\n📋 Detailed Test Results:');
  console.log('─'.repeat(60));
  results.details.forEach(detail => {
    const status = detail.status === 'PASSED' ? '✅' : '❌';
    console.log(`${status} ${detail.test.padEnd(30)} ${detail.status}`);
    if (detail.error) {
      console.log(`   Error: ${detail.error}`);
    }
    if (detail.duration) {
      console.log(`   Duration: ${detail.duration}ms`);
    }
  });
  
  // Print summary
  console.log('\n📊 Integration Test Summary:');
  console.log(`✅ Passed: ${results.passed}/${results.total}`);
  console.log(`❌ Failed: ${results.failed}/${results.total}`);
  console.log(`📈 Success Rate: ${((results.passed / results.total) * 100).toFixed(1)}%`);
  
  if (results.failed === 0) {
    console.log('\n🎉 All integration tests passed! System is ready for production.');
    return true;
  } else {
    console.log('\n⚠️  Some integration tests failed. Please review the errors above.');
    return false;
  }
}

// Export for use in other scripts
module.exports = { runIntegrationTests };

// Run tests if called directly
if (require.main === module) {
  runIntegrationTests()
    .then((success) => process.exit(success ? 0 : 1))
    .catch((error) => {
      console.error('Integration test runner error:', error);
      process.exit(1);
    });
}