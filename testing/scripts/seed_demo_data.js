// Demo data seeding script for integration testing
const { Pool } = require('pg');
const { v4: uuidv4 } = require('uuid');

// Database connection with fallback to SQLite
const pool = new Pool({
  user: process.env.DB_USER || 'postgres',
  host: process.env.DB_HOST || 'localhost',
  database: process.env.DB_NAME || 'inventory_db',
  password: process.env.DB_PASS || 'password',
  port: process.env.DB_PORT || 5432,
});

// Generate demo data with known IDs P-001 to P-020
const generateDemoData = () => {
  const vendors = [
    { id: uuidv4(), name: 'Railway Parts Ltd', email: 'contact@railwayparts.com', phone: '+91-11-2345-6789' },
    { id: uuidv4(), name: 'Metro Components', email: 'info@metrocomp.com', phone: '+91-22-9876-5432' },
    { id: uuidv4(), name: 'Track Systems India', email: 'sales@tracksys.in', phone: '+91-44-1111-2222' },
    { id: uuidv4(), name: 'Signal Tech Solutions', email: 'support@signaltech.co.in', phone: '+91-80-3333-4444' },
    { id: uuidv4(), name: 'Brake Systems Corp', email: 'orders@brakesys.com', phone: '+91-33-5555-6666' }
  ];

  const parts = [];
  const inspections = [];

  for (let i = 1; i <= 20; i++) {
    const partId = `P-${i.toString().padStart(3, '0')}`;
    const vendorId = vendors[i % vendors.length].id;
    
    const part = {
      id: uuidv4(),
      qr_code: partId,
      name: `Railway Part ${partId}`,
      part_number: `RP-2024-${i.toString().padStart(3, '0')}`,
      description: `Demo railway component ${partId}`,
      category: ['brake_system', 'electrical', 'track_system', 'signaling'][i % 4],
      status: 'active',
      quantity: Math.floor(Math.random() * 100) + 10,
      unit_price: Math.floor(Math.random() * 10000) + 1000,
      location: `Warehouse-${String.fromCharCode(65 + (i % 5))}-${i.toString().padStart(2, '0')}`,
      vendor_id: vendorId,
      manufacture_date: new Date(2024, Math.floor(Math.random() * 12), Math.floor(Math.random() * 28) + 1).toISOString().split('T')[0],
      warranty_months: [12, 24, 36, 48][i % 4]
    };
    parts.push(part);

    // Add 1-3 inspections per part
    const numInspections = Math.floor(Math.random() * 3) + 1;
    for (let j = 0; j < numInspections; j++) {
      inspections.push({
        id: uuidv4(),
        part_id: part.id,
        inspector_name: ['Rajesh Kumar', 'Priya Sharma', 'Amit Singh', 'Sunita Patel'][j % 4],
        inspection_date: new Date(2024, Math.floor(Math.random() * 12), Math.floor(Math.random() * 28) + 1).toISOString().split('T')[0],
        inspection_type: ['incoming', 'routine', 'maintenance'][j % 3],
        result: Math.random() > 0.2 ? 'passed' : 'failed',
        score: Math.floor(Math.random() * 40) + 60,
        remarks: `Inspection ${j + 1} for ${partId}`,
        defects_found: Math.random() > 0.7 ? ['Minor wear'] : [],
        corrective_actions: Math.random() > 0.8 ? 'Replace component' : 'None required',
        next_inspection_date: new Date(2024, Math.floor(Math.random() * 12), Math.floor(Math.random() * 28) + 1).toISOString().split('T')[0]
      });
    }
  }

  return { vendors, parts, inspections };
};

async function seedDemoData() {
  const client = await pool.connect();
  try {
    console.log('🌱 Starting demo data seeding...');
    
    const { vendors, parts, inspections } = generateDemoData();

    // Seed vendors
    for (const vendor of vendors) {
      await client.query(`
        INSERT INTO vendors (id, name, email, phone, address, status, created_at, updated_at)
        VALUES ($1, $2, $3, $4, $5, $6, NOW(), NOW())
        ON CONFLICT (id) DO NOTHING
      `, [vendor.id, vendor.name, vendor.email, vendor.phone, 'Demo Address', 'active']);
    }
    console.log(`✓ Seeded ${vendors.length} vendors`);

    // Seed parts
    for (const part of parts) {
      await client.query(`
        INSERT INTO parts (id, qr_code, name, part_number, description, category, status, 
                          quantity, unit_price, location, vendor_id, manufacture_date, 
                          warranty_months, created_at, updated_at)
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, NOW(), NOW())
        ON CONFLICT (qr_code) DO UPDATE SET
        name = EXCLUDED.name, description = EXCLUDED.description
      `, [
        part.id, part.qr_code, part.name, part.part_number, part.description,
        part.category, part.status, part.quantity, part.unit_price, part.location,
        part.vendor_id, part.manufacture_date, part.warranty_months
      ]);
    }
    console.log(`✓ Seeded ${parts.length} parts (P-001 to P-020)`);

    // Seed inspections
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

    console.log('🎉 Demo data seeding completed successfully!');
    
  } catch (error) {
    console.error('❌ Demo data seeding failed:', error);
    throw error;
  } finally {
    client.release();
    await pool.end();
  }
}

if (require.main === module) {
  seedDemoData()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });
}

module.exports = { seedDemoData };