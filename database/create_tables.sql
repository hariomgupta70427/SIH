-- Minimal SQL DDL for Inventory Tracking System
-- Core tables: vendors, parts, inspections

-- VENDORS TABLE
-- Stores supplier information
CREATE TABLE vendors (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    contact_info JSONB, -- Flexible contact information storage
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'inactive')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- PARTS TABLE  
-- Core inventory with QR code tracking
CREATE TABLE parts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    qr_code VARCHAR(255) UNIQUE NOT NULL, -- QR identifier for scanning
    name VARCHAR(255) NOT NULL,
    part_number VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'maintenance')),
    quantity INTEGER DEFAULT 0 CHECK (quantity >= 0),
    unit_price DECIMAL(10,2) CHECK (unit_price >= 0),
    vendor_id UUID NOT NULL REFERENCES vendors(id),
    location VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- INSPECTIONS TABLE
-- Quality control records
CREATE TABLE inspections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    part_id UUID NOT NULL REFERENCES parts(id) ON DELETE CASCADE,
    inspector_name VARCHAR(255) NOT NULL,
    inspection_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    result VARCHAR(20) NOT NULL CHECK (result IN ('passed', 'failed', 'pending')),
    score INTEGER CHECK (score >= 0 AND score <= 100),
    remarks TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Essential indexes for performance
CREATE INDEX idx_parts_qr_code ON parts(qr_code);
CREATE INDEX idx_parts_vendor_id ON parts(vendor_id);
CREATE INDEX idx_inspections_part_id ON inspections(part_id);
CREATE INDEX idx_inspections_date ON inspections(inspection_date);

-- Sample data
INSERT INTO vendors (name, contact_info) VALUES 
('Railway Parts Ltd', '{"email": "contact@railwayparts.com", "phone": "+1-555-0101"}'),
('Metro Components', '{"email": "info@metrocomp.com", "phone": "+1-555-0102"}');

INSERT INTO parts (qr_code, name, part_number, vendor_id, quantity, unit_price, location) VALUES
('QR001', 'Brake Pad Set', 'BP-2024-001', (SELECT id FROM vendors WHERE name = 'Railway Parts Ltd'), 50, 2500.00, 'Warehouse-A'),
('QR002', 'Signal Light', 'SL-2024-002', (SELECT id FROM vendors WHERE name = 'Metro Components'), 25, 8500.00, 'Warehouse-B');