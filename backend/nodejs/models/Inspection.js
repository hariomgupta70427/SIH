const { DataTypes } = require('sequelize');

module.exports = (sequelize) => {
  const Inspection = sequelize.define('Inspection', {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true,
    },
    partId: {
      type: DataTypes.UUID,
      allowNull: false,
    },
    inspectorName: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    inspectionDate: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW,
    },
    status: {
      type: DataTypes.ENUM('passed', 'failed', 'pending'),
      allowNull: false,
    },
    notes: {
      type: DataTypes.TEXT,
    },
    score: {
      type: DataTypes.INTEGER,
      validate: {
        min: 0,
        max: 100,
      },
    },
  });

  return Inspection;
};