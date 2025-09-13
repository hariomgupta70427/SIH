const { Sequelize } = require('sequelize');

// Database connection
const sequelize = new Sequelize(
  process.env.DB_NAME || 'inventory_db',
  process.env.DB_USER || 'postgres',
  process.env.DB_PASS || 'password',
  {
    host: process.env.DB_HOST || 'localhost',
    dialect: 'postgres',
    logging: false,
  }
);

// Import models
const Part = require('./Part')(sequelize);
const Vendor = require('./Vendor')(sequelize);
const Inspection = require('./Inspection')(sequelize);

// Define associations
Vendor.hasMany(Part, { foreignKey: 'vendorId' });
Part.belongsTo(Vendor, { foreignKey: 'vendorId' });

Part.hasMany(Inspection, { foreignKey: 'partId' });
Inspection.belongsTo(Part, { foreignKey: 'partId' });

module.exports = {
  sequelize,
  Part,
  Vendor,
  Inspection,
};