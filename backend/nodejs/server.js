const express = require('express');
const cors = require('cors');
require('dotenv').config();

const { sequelize } = require('./models');
const partRoutes = require('./routes/parts');
const vendorRoutes = require('./routes/vendors');
const inspectionRoutes = require('./routes/inspections');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors({
  origin: ['http://localhost:3000', 'http://10.0.2.2:3000', 'http://localhost:8080'],
  credentials: true
}));
app.use(express.json());

// Routes
app.use('/api/parts', partRoutes);
app.use('/api/vendors', vendorRoutes);
app.use('/api/inspections', inspectionRoutes);

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({ status: 'OK', timestamp: new Date().toISOString() });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Something went wrong!' });
});

// Start server and sync database
async function startServer() {
  try {
    await sequelize.authenticate();
    console.log('Database connected successfully');
    
    // Sync models (create tables if they don't exist)
    await sequelize.sync({ alter: true });
    
    app.listen(PORT, () => {
      console.log(`Server running on port ${PORT}`);
    });
  } catch (error) {
    console.error('Unable to start server:', error);
  }
}

startServer();