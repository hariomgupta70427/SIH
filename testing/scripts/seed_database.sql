-- SQL script for database seeding (alternative to Node.js script)
-- Run this script to populate the database with sample data

-- Clear existing data (optional)
-- TRUNCATE TABLE inspections, parts, vendors RESTART IDENTITY CASCADE;

-- Insert sample vendors
INSERT INTO vendors (id, name, email, phone, address, status, created_at, updated_at) VALUES
('550e8400-e29b-41d4-a716-446655440001', 'Railway Parts Ltd', 'contact@railwayparts.com', '+91-11-2345-6789', '123 Industrial Area, New Delhi, India', 'active', NOW(), NOW()),
('550e8400-e29b-41d4-a716-446655440002', 'Metro Components Pvt Ltd', 'info@metrocomp.com', '+91-22-9876-5432', '456 Manufacturing Hub, Mumbai, India', 'active', NOW(), NOW()),
('550e8400-e29b-41d4-a716-446655440003', 'Track Systems India', 'sales@tracksys.in', '+91-44-1111-2222', '789 Railway Road, Chennai, India', 'active', NOW(), NOW()),
('550e8400-e29b-41d4-a716-446655440004', 'Signal Tech Solutions', 'support@signaltech.co.in', '+91-80-3333-4444', '321 Tech Park, Bangalore, India', 'active', NOW(), NOW()),
('550e8400-e29b-41d4-a716-446655440005', 'Brake Systems Corp', 'orders@brakesys.com', '+91-33-5555-6666', '654 Industrial Zone, Kolkata, India', 'inactive', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- Insert sample parts
INSERT INTO parts (id, qr_code, name, part_number, description, category, status, quantity, unit_price, location, vendor_id, manufacture_date, warranty_months, created_at, updated_at) VALUES
('650e8400-e29b-41d4-a716-446655440001', 'QR001', 'Brake Pad Assembly', 'BP-2024-001', 'High-performance brake pads for metro trains', 'brake_system', 'active', 150, 2500.00, 'Warehouse-A-01', '550e8400-e29b-41d4-a716-446655440001', '2024-01-15', 24, NOW(), NOW()),
('650e8400-e29b-41d4-a716-446655440002', 'QR002', 'LED Signal Light Assembly', 'SL-2024-002', 'LED signal light with controller unit', 'electrical', 'active', 75, 8500.00, 'Warehouse-B-03', '550e8400-e29b-41d4-a716-446655440002', '2024-02-10', 36, NOW(), NOW()),
('650e8400-e29b-41d4-a716-446655440003', 'QR003', 'Rail Fastener Kit', 'RF-2024-003', 'Complete fastener kit for track installation', 'track_system', 'active', 200, 450.00, 'Warehouse-C-05', '550e8400-e29b-41d4-a716-446655440003', '2024-01-20', 12, NOW(), NOW()),
('650e8400-e29b-41d4-a716-446655440004', 'QR004', 'Digital Signal Controller', 'DSC-2024-004', 'Advanced digital signal processing unit', 'electrical', 'active', 45, 15000.00, 'Warehouse-D-02', '550e8400-e29b-41d4-a716-446655440004', '2024-02-05', 48, NOW(), NOW()),
('650e8400-e29b-41d4-a716-446655440005', 'QR005', 'Hydraulic Brake Cylinder', 'HBC-2024-005', 'Heavy-duty hydraulic brake cylinder', 'brake_system', 'maintenance', 25, 12000.00, 'Warehouse-E-01', '550e8400-e29b-41d4-a716-446655440005', '2024-01-30', 30, NOW(), NOW()),
('650e8400-e29b-41d4-a716-446655440006', 'QR006', 'Track Circuit Module', 'TCM-2024-006', 'Electronic track circuit detection module', 'track_system', 'active', 60, 6500.00, 'Warehouse-F-04', '550e8400-e29b-41d4-a716-446655440003', '2024-02-15', 24, NOW(), NOW())
ON CONFLICT (qr_code) DO NOTHING;

-- Insert sample inspections
INSERT INTO inspections (id, part_id, inspector_name, inspection_date, inspection_type, result, score, remarks, defects_found, corrective_actions, next_inspection_date, created_at, updated_at) VALUES
('750e8400-e29b-41d4-a716-446655440001', '650e8400-e29b-41d4-a716-446655440001', 'Rajesh Kumar', '2024-01-20', 'incoming', 'passed', 95, 'Excellent condition, all specifications met', '[]', 'None required', '2024-04-20', NOW(), NOW()),
('750e8400-e29b-41d4-a716-446655440002', '650e8400-e29b-41d4-a716-446655440002', 'Priya Sharma', '2024-02-12', 'routine', 'passed', 88, 'Good condition, minor wear observed', '["Minor surface scratches"]', 'Surface polishing recommended', '2024-05-12', NOW(), NOW()),
('750e8400-e29b-41d4-a716-446655440003', '650e8400-e29b-41d4-a716-446655440003', 'Amit Singh', '2024-01-25', 'incoming', 'failed', 65, 'Fastener torque below specification', '["Insufficient torque", "Thread damage on 2 bolts"]', 'Replace damaged bolts, re-torque all fasteners', '2024-02-01', NOW(), NOW()),
('750e8400-e29b-41d4-a716-446655440004', '650e8400-e29b-41d4-a716-446655440004', 'Sunita Patel', '2024-02-08', 'routine', 'passed', 92, 'All electronic tests passed, firmware updated', '[]', 'Firmware update completed', '2024-05-08', NOW(), NOW()),
('750e8400-e29b-41d4-a716-446655440005', '650e8400-e29b-41d4-a716-446655440005', 'Vikram Gupta', '2024-02-01', 'maintenance', 'requires_attention', 72, 'Hydraulic seal showing signs of wear', '["Seal deterioration", "Minor fluid leak"]', 'Schedule seal replacement within 30 days', '2024-03-01', NOW(), NOW()),
('750e8400-e29b-41d4-a716-446655440006', '650e8400-e29b-41d4-a716-446655440006', 'Meera Reddy', '2024-02-18', 'incoming', 'passed', 90, 'Circuit functionality verified, all tests passed', '[]', 'None required', '2024-05-18', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- Verify data insertion
SELECT 'Vendors' as table_name, COUNT(*) as record_count FROM vendors
UNION ALL
SELECT 'Parts' as table_name, COUNT(*) as record_count FROM parts
UNION ALL
SELECT 'Inspections' as table_name, COUNT(*) as record_count FROM inspections;