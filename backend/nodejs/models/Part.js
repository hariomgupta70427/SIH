const { DataTypes } = require('sequelize');

module.exports = (sequelize) => {
  const Part = sequelize.define('Part', {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true,
    },
    name: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    partNumber: {
      type: DataTypes.STRING,
      unique: true,
      allowNull: false,
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
    },
    price: {
      type: DataTypes.DECIMAL(10, 2),
    },
    vendorId: {
      type: DataTypes.UUID,
      allowNull: false,
    },
  });

  return Part;
};