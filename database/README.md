# Database Schema for Inventory Tracking System

## Overview
Database schema for QR-based railway parts inventory management system with support for PostgreSQL and Firebase.

## Core Tables/Collections

### 1. VENDORS
Stores supplier and manufacturer information
- **id**: UUID primary key
- **name**: Vendor company name
- **contact_info**: Contact details (email, phone, address)
- **status**: active, inactive, suspended
- **created_at/updated_at**: Timestamps

### 2. PARTS
Core inventory items with QR code tracking
- **id**: UUID primary key
- **qr_code**: Unique QR identifier for scanning
- **name**: Part name/description
- **part_number**: Manufacturer part number (unique)
- **description**: Detailed description
- **status**: active, inactive, maintenance, retired
- **quantity**: Current stock level
- **unit_price**: Price per unit
- **vendor_id**: Foreign key to vendors table
- **location**: Storage location/warehouse section
- **created_at/updated_at**: Timestamps

### 3. INSPECTIONS
Quality control and maintenance records
- **id**: UUID primary key
- **part_id**: Foreign key to parts table
- **inspector_name**: Name of inspector
- **inspection_date**: Date/time of inspection
- **result**: passed, failed, pending, requires_attention
- **score**: Quality score (0-100)
- **remarks**: Inspection notes
- **created_at**: Timestamp

## Relationships
- Vendors → Parts (One-to-Many)
- Parts → Inspections (One-to-Many)

## Key Indexes
- parts.qr_code (unique)
- parts.part_number (unique)
- parts.vendor_id
- inspections.part_id
- inspections.inspection_date

## Files Included
- `postgresql_schema.sql` - Complete PostgreSQL schema with advanced features
- `create_tables.sql` - Minimal SQL DDL for core functionality
- `firebase_schema.json` - Firestore collection structure
- `sequelize_models.js` - Node.js Sequelize ORM models
- `django_models.py` - Django ORM models

## Usage
1. For PostgreSQL: Run `postgresql_schema.sql` or `create_tables.sql`
2. For Firebase: Use structure from `firebase_schema.json`
3. For Node.js: Import models from `sequelize_models.js`
4. For Django: Use models from `django_models.py`