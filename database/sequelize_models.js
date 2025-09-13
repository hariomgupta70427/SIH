// Sequelize ORM Models for Inventory System
const { DataTypes } = require('sequelize');

// VENDOR MODEL
const Vendor = (sequelize) => sequelize.define('Vendor', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  name: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  contactInfo: {
    type: DataTypes.JSONB, // Flexible contact storage
    defaultValue: {},
  },
  status: {
    type: DataTypes.ENUM('active', 'inactive'),
    defaultValue: 'active',
  },
});

// PART MODEL
const Part = (sequelize) => sequelize.define('Part', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  qrCode: {
    type: DataTypes.STRING,
    unique: true,
    allowNull: false,
    field: 'qr_code',
  },
  name: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  partNumber: {
    type: DataTypes.STRING,
    unique: true,
    allowNull: false,
    field: 'part_number',
  },
  description: {
    type: DataTypes.TEXT,
  },
  status: {
    type: DataTypes.ENUM('active', 'inactive', 'maintenance'),
    defaultValue: 'active',
  },
  quantity: {
    type: DataTypes.INTEGER,
    defaultValue: 0,
    validate: { min: 0 },
  },
  unitPrice: {
    type: DataTypes.DECIMAL(10, 2),
    field: 'unit_price',
    validate: { min: 0 },
  },
  vendorId: {
    type: DataTypes.UUID,
    allowNull: false,
    field: 'vendor_id',
  },
  location: {
    type: DataTypes.STRING,
  },
});

// INSPECTION MODEL
const Inspection = (sequelize) => sequelize.define('Inspection', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  partId: {
    type: DataTypes.UUID,
    allowNull: false,
    field: 'part_id',
  },
  inspectorName: {
    type: DataTypes.STRING,
    allowNull: false,
    field: 'inspector_name',
  },
  inspectionDate: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW,
    field: 'inspection_date',
  },
  result: {
    type: DataTypes.ENUM('passed', 'failed', 'pending'),
    allowNull: false,
  },
  score: {
    type: DataTypes.INTEGER,
    validate: { min: 0, max: 100 },
  },
  remarks: {
    type: DataTypes.TEXT,
  },
});

// DEFINE ASSOCIATIONS
const defineAssociations = (models) => {
  const { Vendor, Part, Inspection } = models;
  
  // Vendor has many Parts
  Vendor.hasMany(Part, { foreignKey: 'vendorId', as: 'parts' });
  Part.belongsTo(Vendor, { foreignKey: 'vendorId', as: 'vendor' });
  
  // Part has many Inspections
  Part.hasMany(Inspection, { foreignKey: 'partId', as: 'inspections' });
  Inspection.belongsTo(Part, { foreignKey: 'partId', as: 'part' });
};

module.exports = {
  Vendor,
  Part,
  Inspection,
  defineAssociations,
};