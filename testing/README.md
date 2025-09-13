# Integration Testing Suite

## Overview
Comprehensive testing suite for the Railway Parts Management System including database seeding, API testing, and end-to-end integration tests.

## Components

### 1. Database Seeding (`scripts/seed_database.js`)
- **Purpose**: Populate database with realistic test data
- **Data Generated**:
  - 5 vendors with contact information
  - 6 parts with QR codes and specifications
  - 6 inspection records with various results
- **Usage**: `npm run seed`

### 2. API Endpoint Testing (`scripts/test_api_endpoints.js`)
- **Purpose**: Validate all REST API endpoints
- **Tests Covered**:
  - GET /api/parts (list and by ID)
  - POST /api/parts (create)
  - PUT /api/parts/:id (update)
  - GET /api/vendors
  - GET /api/inspections
  - QR code lookup functionality
- **Usage**: `npm run test:api`

### 3. Flutter Integration Tests (`../integration_test/app_test.dart`)
- **Purpose**: End-to-end testing of mobile app
- **Test Scenarios**:
  - Complete QR scanning workflow
  - Error handling for invalid QR codes
  - Network error handling
  - Camera permissions
  - Flash toggle functionality
- **Usage**: `flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_test.dart`

### 4. End-to-End Integration (`integration/end_to_end_test.js`)
- **Purpose**: Complete system workflow testing
- **Test Coverage**:
  - QR code scanning simulation
  - Part data retrieval
  - Inspection workflows
  - Status updates
  - System performance
- **Usage**: `npm run test:integration`

## Sample Data

### Vendors
```javascript
{
  name: 'Railway Parts Ltd',
  email: 'contact@railwayparts.com',
  phone: '+91-11-2345-6789',
  address: '123 Industrial Area, New Delhi, India',
  status: 'active'
}
```

### Parts
```javascript
{
  qr_code: 'QR001',
  name: 'Brake Pad Assembly',
  part_number: 'BP-2024-001',
  category: 'brake_system',
  quantity: 150,
  unit_price: 2500.00,
  location: 'Warehouse-A-01'
}
```

### Inspections
```javascript
{
  inspector_name: 'Rajesh Kumar',
  inspection_type: 'incoming',
  result: 'passed',
  score: 95,
  remarks: 'Excellent condition, all specifications met'
}
```

## Installation

### Prerequisites
```bash
# Node.js dependencies
cd testing/scripts
npm install

# Flutter dependencies
flutter pub get
flutter pub get --directory=integration_test
```

### Environment Setup
```bash
# Database configuration
export DB_NAME=inventory_db
export DB_USER=postgres
export DB_PASSWORD=password
export DB_HOST=localhost

# API configuration
export API_BASE_URL=http://localhost:3000/api
```

## Usage

### Quick Setup
```bash
# Install dependencies and seed database
npm run setup
```

### Individual Tests

**Database Seeding:**
```bash
cd testing/scripts
npm run seed
```

**API Testing:**
```bash
cd testing/scripts
npm run test:api
```

**Flutter Integration Tests:**
```bash
# From project root
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_test.dart
```

**End-to-End Integration:**
```bash
cd testing/scripts
npm run test:integration
```

## Test Scenarios

### QR Scanning Workflow
1. **App Launch**: Verify authentication screen
2. **Login**: Test with mock credentials
3. **Navigation**: Access QR scanner
4. **QR Detection**: Simulate QR code scanning
5. **Data Retrieval**: Fetch part information from API
6. **Display**: Show part details and analytics
7. **Actions**: Test scan another and view details

### Error Handling
1. **Invalid QR Codes**: Test non-existent QR codes
2. **Network Errors**: Simulate API failures
3. **Permission Errors**: Test camera permissions
4. **Data Validation**: Test malformed responses

### Performance Testing
1. **Concurrent Requests**: Multiple simultaneous API calls
2. **Response Times**: Measure API response latency
3. **Data Volume**: Test with large datasets
4. **Memory Usage**: Monitor resource consumption

## Expected Results

### Database Seeding
```
✓ Seeded 5 vendors
✓ Seeded 6 parts
✓ Seeded 6 inspections
```

### API Testing
```
✓ GET /api/parts - Success (6 parts)
✓ GET /api/parts/:id - Success (Brake Pad Assembly)
✓ POST /api/parts - Success (ID: uuid)
✓ PUT /api/parts/:id - Success (Updated quantity: 15)
✓ GET /api/inspections - Success (6 inspections)
```

### Integration Testing
```
✓ QR Code Scanning Workflow - PASSED
✓ Inspection Data Retrieval - PASSED
✓ Part Status Update - PASSED
✓ System Performance - PASSED (1250ms)
```

## Troubleshooting

### Common Issues

**Database Connection:**
```bash
# Check PostgreSQL is running
pg_isready -h localhost -p 5432

# Verify database exists
psql -h localhost -U postgres -l
```

**API Server:**
```bash
# Check server is running
curl http://localhost:3000/health

# Check API endpoints
curl http://localhost:3000/api/parts
```

**Flutter Tests:**
```bash
# Check Flutter installation
flutter doctor

# Verify integration_test package
flutter packages get
```

### Test Data Reset
```bash
# Clear and reseed database
npm run seed
```

### Performance Issues
- Increase timeout values in test configuration
- Check database indexes are created
- Monitor system resources during tests

## Continuous Integration

### GitHub Actions Example
```yaml
name: Integration Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:13
        env:
          POSTGRES_PASSWORD: password
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
    steps:
      - uses: actions/checkout@v2
      - name: Setup Node.js
        uses: actions/setup-node@v2
        with:
          node-version: '18'
      - name: Install dependencies
        run: cd testing/scripts && npm install
      - name: Run integration tests
        run: cd testing/scripts && npm run test:integration
```

## File Structure
```
testing/
├── scripts/
│   ├── seed_database.js       # Database seeding
│   ├── seed_database.sql      # SQL seeding alternative
│   ├── test_api_endpoints.js  # API testing
│   └── package.json           # Dependencies
├── integration/
│   └── end_to_end_test.js     # E2E integration tests
├── data/                      # Test data files
└── README.md                  # This file

integration_test/
└── app_test.dart              # Flutter integration tests
```