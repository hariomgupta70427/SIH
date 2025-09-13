// Database seeding script for integration testing
const { Pool } = require('pg');
const { v4: uuidv4 } = require('uuid');

// Database connection configuration
const pool = new Pool({
  user: process.env.DB_USER || 'postgres',
  host: process.env.DB_HOST || 'localhost',
  database: process.env.DB_NAME || 'inventory_db',
  password: process.env.DB_PASSWORD || 'password',
  port: process.env.DB_PORT || 5432,
});

// Sample data generators
const generateVendors = () => [
  {
    id: uuidv4(),
    name: 'Railway Parts Ltd',
    email: 'contact@railwayparts.com',
    phone: '+91-11-2345-6789',
    address: '123 Industrial Area, New Delhi, India',
    status: 'active'
  },
  {
    id: uuidv4(),
    name: 'Metro Components Pvt Ltd',
    email: 'info@metrocomp.com',
    phone: '+91-22-9876-5432',
    address: '456 Manufacturing Hub, Mumbai, India',
    status: 'active'
  },
  {
    id: uuidv4(),
    name: 'Track Systems India',
    email: 'sales@tracksys.in',
    phone: '+91-44-1111-2222',
    address: '789 Railway Road, Chennai, India',
    status: 'active'
  },
  {
    id: uuidv4(),
    name: 'Signal Tech Solutions',
    email: 'support@signaltech.co.in',
    phone: '+91-80-3333-4444',
    address: '321 Tech Park, Bangalore, India',
    status: 'active'
  },
  {
    id: uuidv4(),
    name: 'Brake Systems Corp',
    email: 'orders@brakesys.com',
    phone: '+91-33-5555-6666',
    address: '654 Industrial Zone, Kolkata, India',
    status: 'inactive'
  }
];

const generateParts = (vendors) => [
  {
    id: uuidv4(),
    qr_code: 'QR001',
    name: 'Brake Pad Assembly',
    part_number: 'BP-2024-001',
    description: 'High-performance brake pads for metro trains',
    category: 'brake_system',
    status: 'active',
    quantity: 150,
    unit_price: 2500.00,
    location: 'Warehouse-A-01',
    vendor_id: vendors[0].id,
    manufacture_date: '2024-01-15',
    warranty_months: 24
  },
  {
    id: uuidv4(),
    qr_code: 'QR002',
    name: 'LED Signal Light Assembly',
    part_number: 'SL-2024-002',
    description: 'LED signal light with controller unit',
    category: 'electrical',
    status: 'active',
    quantity: 75,
    unit_price: 8500.00,
    location: 'Warehouse-B-03',
    vendor_id: vendors[1].id,
    manufacture_date: '2024-02-10',
    warranty_months: 36
  },
  {
    id: uuidv4(),
    qr_code: 'QR003',
    name: 'Rail Fastener Kit',
    part_number: 'RF-2024-003',
    description: 'Complete fastener kit for track installation',
    category: 'track_system',
    status: 'active',
    quantity: 200,
    unit_price: 450.00,
    location: 'Warehouse-C-05',
    vendor_id: vendors[2].id,
    manufacture_date: '2024-01-20',
    warranty_months: 12
  },
  {
    id: uuidv4(),
    qr_code: 'QR004',
    name: 'Digital Signal Controller',
    part_number: 'DSC-2024-004',
    description: 'Advanced digital signal processing unit',
    category: 'electrical',
    status: 'active',
    quantity: 45,
    unit_price: 15000.00,
    location: 'Warehouse-D-02',
    vendor_id: vendors[3].id,
    manufacture_date: '2024-02-05',
    warranty_months: 48
  },
  {
    id: uuidv4(),
    qr_code: 'QR005',
    name: 'Hydraulic Brake Cylinder',
    part_number: 'HBC-2024-005',
    description: 'Heavy-duty hydraulic brake cylinder',
    category: 'brake_system',
    status: 'maintenance',
    quantity: 25,
    unit_price: 12000.00,
    location: 'Warehouse-E-01',
    vendor_id: vendors[4].id,
    manufacture_date: '2024-01-30',
    warranty_months: 30
  },
  {
    id: uuidv4(),
    qr_code: 'QR006',
    name: 'Track Circuit Module',
    part_number: 'TCM-2024-006',
    description: 'Electronic track circuit detection module',
    category: 'track_system',
    status: 'active',
    quantity: 60,
    unit_price: 6500.00,
    location: 'Warehouse-F-04',
    vendor_id: vendors[2].id,
    manufacture_date: '2024-02-15',
    warranty_months: 24
  }
];

const generateInspections = (parts) => [
  {
    id: uuidv4(),
    part_id: parts[0].id,
    inspector_name: 'Rajesh Kumar',
    inspection_date: '2024-01-20',
    inspection_type: 'incoming',
    result: 'passed',
    score: 95,
    remarks: 'Excellent condition, all specifications met',
    defects_found: [],
    corrective_actions: 'None required',
    next_inspection_date: '2024-04-20'
  },
  {
    id: uuidv4(),
    part_id: parts[1].id,
    inspector_name: 'Priya Sharma',
    inspection_date: '2024-02-12',
    inspection_type: 'routine',
    result: 'passed',
    score: 88,
    remarks: 'Good condition, minor wear observed',
    defects_found: ['Minor surface scratches'],
    corrective_actions: 'Surface polishing recommended',
    next_inspection_date: '2024-05-12'
  },
  {
    id: uuidv4(),
    part_id: parts[2].id,
    inspector_name: 'Amit Singh',
    inspection_date: '2024-01-25',
    inspection_type: 'incoming',
    result: 'failed',
    score: 65,
    remarks: 'Fastener torque below specification',
    defects_found: ['Insufficient torque', 'Thread damage on 2 bolts'],
    corrective_actions: 'Replace damaged bolts, re-torque all fasteners',
    next_inspection_date: '2024-02-01'
  },
  {
    id: uuidv4(),
    part_id: parts[3].id,
    inspector_name: 'Sunita Patel',
    inspection_date: '2024-02-08',
    inspection_type: 'routine',
    result: 'passed',
    score: 92,
    remarks: 'All electronic tests passed, firmware updated',
    defects_found: [],
    corrective_actions: 'Firmware update completed',
    next_inspection_date: '2024-05-08'
  },
  {
    id: uuidv4(),
    part_id: parts[4].id,
    inspector_name: 'Vikram Gupta',
    inspection_date: '2024-02-01',
    inspection_type: 'maintenance',
    result: 'requires_attention',
    score: 72,
    remarks: 'Hydraulic seal showing signs of wear',
    defects_found: ['Seal deterioration', 'Minor fluid leak'],
    corrective_actions: 'Schedule seal replacement within 30 days',
    next_inspection_date: '2024-03-01'
  },
  {
    id: uuidv4(),
    part_id: parts[5].id,
    inspector_name: 'Meera Reddy',
    inspection_date: '2024-02-18',
    inspection_type: 'incoming',
    result: 'passed',
    score: 90,
    remarks: 'Circuit functionality verified, all tests passed',
    defects_found: [],
    corrective_actions: 'None required',
    next_inspection_date: '2024-05-18'
  }
];

// Database seeding functions
async function seedVendors(vendors) {
  const client = await pool.connect();
  try {
    console.log('Seeding vendors...');
    
    for (const vendor of vendors) {
      await client.query(`
        INSERT INTO vendors (id, name, email, phone, address, status, created_at, updated_at)
        VALUES ($1, $2, $3, $4, $5, $6, NOW(), NOW())
        ON CONFLICT (id) DO NOTHING
      `, [vendor.id, vendor.name, vendor.email, vendor.phone, vendor.address, vendor.status]);
    }
    
    console.log(`✓ Seeded ${vendors.length} vendors`);
  } finally {
    client.release();
  }
}

async function seedParts(parts) {
  const client = await pool.connect();
  try {
    console.log('Seeding parts...');
    
    for (const part of parts) {
      await client.query(`
        INSERT INTO parts (id, qr_code, name, part_number, description, category, status, 
                          quantity, unit_price, location, vendor_id, manufacture_date, 
                          warranty_months, created_at, updated_at)
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, NOW(), NOW())
        ON CONFLICT (qr_code) DO NOTHING
      `, [
        part.id, part.qr_code, part.name, part.part_number, part.description,
        part.category, part.status, part.quantity, part.unit_price, part.location,
        part.vendor_id, part.manufacture_date, part.warranty_months
      ]);
    }
    
    console.log(`✓ Seeded ${parts.length} parts`);
  } finally {
    client.release();
  }
}

async function seedInspections(inspections) {
  const client = await pool.connect();
  try {
    console.log('Seeding inspections...');
    
    for (const inspection of inspections) {
      await client.query(`
        INSERT INTO inspections (id, part_id, inspector_name, inspection_date, 
                               inspection_type, result, score, remarks, defects_found,
                               corrective_actions, next_inspection_date, created_at, updated_at)
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, NOW(), NOW())
        ON CONFLICT (id) DO NOTHING
      `, [
        inspection.id, inspection.part_id, inspection.inspector_name,
        inspection.inspection_date, inspection.inspection_type, inspection.result,
        inspection.score, inspection.remarks, JSON.stringify(inspection.defects_found),
        inspection.corrective_actions, inspection.next_inspection_date
      ]);
    }
    
    console.log(`✓ Seeded ${inspections.length} inspections`);
  } finally {
    client.release();
  }
}

// Main seeding function
async function seedDatabase() {
  try {
    console.log('Starting database seeding...\n');
    
    // Generate sample data
    const vendors = generateVendors();
    const parts = generateParts(vendors);
    const inspections = generateInspections(parts);
    
    // Seed data in order (vendors first, then parts, then inspections)
    await seedVendors(vendors);
    await seedParts(parts);
    await seedInspections(inspections);
    
    console.log('\n✅ Database seeding completed successfully!');
    console.log(`Summary:`);
    console.log(`- ${vendors.length} vendors`);
    console.log(`- ${parts.length} parts`);
    console.log(`- ${inspections.length} inspections`);
    
  } catch (error) {
    console.error('❌ Database seeding failed:', error);
    throw error;
  } finally {
    await pool.end();
  }
}

// Export for use in other scripts
module.exports = {
  seedDatabase,
  generateVendors,
  generateParts,
  generateInspections
};

// Run seeding if called directly
if (require.main === module) {
  seedDatabase()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });
}