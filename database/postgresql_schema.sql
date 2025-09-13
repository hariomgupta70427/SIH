-- PostgreSQL Database Schema for Inventory Tracking System
-- Created for QR-based railway parts inventory management

-- Enable UUID extension for generating UUIDs
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create ENUM types for status fields
CREATE TYPE vendor_status AS ENUM ('active', 'inactive', 'suspended');
CREATE TYPE part_status AS ENUM ('active', 'inactive', 'maintenance', 'retired');
CREATE TYPE inspection_result AS ENUM ('passed', 'failed', 'pending', 'requires_attention');

-- VENDORS TABLE
-- Stores supplier/manufacturer information
CREATE TABLE vendors (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    contact_person VARCHAR(255),
    email VARCHAR(255) UNIQUE,
    phone VARCHAR(20),
    address TEXT,
    status vendor_status DEFAULT 'active',
    registration_number VARCHAR(100), -- Government registration/license number
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- PARTS TABLE
-- Core inventory items with QR code tracking
CREATE TABLE parts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    qr_code VARCHAR(255) UNIQUE NOT NULL, -- QR code identifier for scanning
    name VARCHAR(255) NOT NULL,
    part_number VARCHAR(100) UNIQUE NOT NULL, -- Manufacturer part number
    description TEXT,
    category VARCHAR(100), -- e.g., 'brake_system', 'engine', 'electrical'
    status part_status DEFAULT 'active',
    quantity INTEGER DEFAULT 0 CHECK (quantity >= 0),
    unit_price DECIMAL(12,2) CHECK (unit_price >= 0),
    location VARCHAR(255), -- Storage location/warehouse section
    vendor_id UUID NOT NULL REFERENCES vendors(id) ON DELETE RESTRICT,
    manufacture_date DATE,
    warranty_months INTEGER DEFAULT 0,
    critical_level INTEGER DEFAULT 10, -- Minimum stock alert level
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- INSPECTIONS TABLE
-- Quality control and maintenance records
CREATE TABLE inspections (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    part_id UUID NOT NULL REFERENCES parts(id) ON DELETE CASCADE,
    inspector_name VARCHAR(255) NOT NULL,
    inspection_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    inspection_type VARCHAR(50) DEFAULT 'routine', -- 'routine', 'incoming', 'maintenance'
    result inspection_result NOT NULL,
    score INTEGER CHECK (score >= 0 AND score <= 100), -- Quality score 0-100
    remarks TEXT,
    defects_found TEXT[], -- Array of defect descriptions
    corrective_actions TEXT,
    next_inspection_date DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- PART_MOVEMENTS TABLE
-- Track inventory movements (in/out/transfer)
CREATE TABLE part_movements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    part_id UUID NOT NULL REFERENCES parts(id) ON DELETE CASCADE,
    movement_type VARCHAR(20) NOT NULL CHECK (movement_type IN ('in', 'out', 'transfer', 'adjustment')),
    quantity INTEGER NOT NULL,
    from_location VARCHAR(255),
    to_location VARCHAR(255),
    reference_number VARCHAR(100), -- PO number, work order, etc.
    performed_by VARCHAR(255) NOT NULL,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- MAINTENANCE_SCHEDULES TABLE
-- Preventive maintenance scheduling
CREATE TABLE maintenance_schedules (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    part_id UUID NOT NULL REFERENCES parts(id) ON DELETE CASCADE,
    schedule_type VARCHAR(50) NOT NULL, -- 'time_based', 'usage_based', 'condition_based'
    frequency_days INTEGER, -- For time-based maintenance
    last_maintenance_date DATE,
    next_maintenance_date DATE NOT NULL,
    maintenance_instructions TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for performance optimization
CREATE INDEX idx_parts_qr_code ON parts(qr_code);
CREATE INDEX idx_parts_part_number ON parts(part_number);
CREATE INDEX idx_parts_vendor_id ON parts(vendor_id);
CREATE INDEX idx_parts_status ON parts(status);
CREATE INDEX idx_parts_category ON parts(category);

CREATE INDEX idx_inspections_part_id ON inspections(part_id);
CREATE INDEX idx_inspections_date ON inspections(inspection_date);
CREATE INDEX idx_inspections_result ON inspections(result);

CREATE INDEX idx_vendors_status ON vendors(status);
CREATE INDEX idx_vendors_email ON vendors(email);

CREATE INDEX idx_movements_part_id ON part_movements(part_id);
CREATE INDEX idx_movements_type ON part_movements(movement_type);
CREATE INDEX idx_movements_date ON part_movements(created_at);

CREATE INDEX idx_maintenance_part_id ON maintenance_schedules(part_id);
CREATE INDEX idx_maintenance_next_date ON maintenance_schedules(next_maintenance_date);

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers to automatically update updated_at
CREATE TRIGGER update_vendors_updated_at BEFORE UPDATE ON vendors
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_parts_updated_at BEFORE UPDATE ON parts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_inspections_updated_at BEFORE UPDATE ON inspections
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_maintenance_updated_at BEFORE UPDATE ON maintenance_schedules
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Insert sample data for testing
INSERT INTO vendors (name, contact_person, email, phone, address, registration_number) VALUES
('Railway Parts Ltd', 'John Smith', 'contact@railwayparts.com', '+1-555-0101', '123 Industrial Ave, Mumbai', 'REG001'),
('Metro Components', 'Sarah Johnson', 'info@metrocomp.com', '+1-555-0102', '456 Manufacturing St, Delhi', 'REG002'),
('Track Systems Inc', 'Mike Wilson', 'sales@tracksys.com', '+1-555-0103', '789 Railway Rd, Chennai', 'REG003');

-- Sample parts data
INSERT INTO parts (qr_code, name, part_number, description, category, quantity, unit_price, location, vendor_id, manufacture_date, warranty_months) VALUES
('QR001', 'Brake Pad Set', 'BP-2024-001', 'High-performance brake pads for metro trains', 'brake_system', 50, 2500.00, 'Warehouse-A-01', (SELECT id FROM vendors WHERE name = 'Railway Parts Ltd'), '2024-01-15', 24),
('QR002', 'Signal Light Assembly', 'SL-2024-002', 'LED signal light with controller', 'electrical', 25, 8500.00, 'Warehouse-B-03', (SELECT id FROM vendors WHERE name = 'Metro Components'), '2024-02-10', 36),
('QR003', 'Rail Fastener Kit', 'RF-2024-003', 'Complete fastener kit for track installation', 'track_system', 100, 450.00, 'Warehouse-C-05', (SELECT id FROM vendors WHERE name = 'Track Systems Inc'), '2024-01-20', 12);