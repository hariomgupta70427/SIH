const express = require('express');
const { Part, Vendor } = require('../models');
const router = express.Router();

// GET /parts - List all parts with optional filtering
router.get('/', async (req, res) => {
  try {
    const { status, vendorId, limit = 50, offset = 0 } = req.query;
    const where = {};
    
    if (status) where.status = status;
    if (vendorId) where.vendorId = vendorId;

    const parts = await Part.findAll({
      where,
      include: [{ model: Vendor, attributes: ['name', 'email'] }],
      limit: parseInt(limit),
      offset: parseInt(offset),
      order: [['createdAt', 'DESC']],
    });

    res.json(parts);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// GET /parts/:id - Get specific part by ID or QR code
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    
    // Try to find by primary key first, then by QR code
    let part = await Part.findByPk(id, {
      include: [{ 
        model: Vendor,
        attributes: ['id', 'name', 'email', 'phone']
      }],
    });
    
    // If not found by ID, try finding by QR code
    if (!part) {
      part = await Part.findOne({
        where: { qr_code: id },
        include: [{ 
          model: Vendor,
          attributes: ['id', 'name', 'email', 'phone']
        }],
      });
    }

    if (!part) {
      // Return mock data for demo if part not found
      const mockPart = {
        id: id,
        qr_code: id,
        name: `Demo Part ${id}`,
        part_number: `DEMO-${id}`,
        description: `Demo railway component for ${id}`,
        category: 'demo',
        status: 'active',
        quantity: 1,
        unit_price: 1000,
        location: 'Demo Warehouse',
        manufacture_date: '2024-01-01',
        warranty_months: 24,
        vendor: {
          id: 'demo-vendor',
          name: 'Demo Vendor Ltd',
          email: 'demo@vendor.com',
          phone: '+91-99999-99999'
        },
        inspections: [
          {
            id: 'demo-inspection',
            inspection_date: '2024-01-15',
            inspection_type: 'routine',
            result: 'passed',
            score: 85,
            remarks: 'Demo inspection record'
          }
        ],
        createdAt: '2024-01-01T00:00:00Z',
        updatedAt: '2024-01-01T00:00:00Z'
      };
      return res.json(mockPart);
    }

    // Fetch inspections for this part
    const { Inspection } = require('../models');
    const inspections = await Inspection.findAll({
      where: { part_id: part.id },
      order: [['inspection_date', 'DESC']],
      limit: 5
    });

    // Add inspections to response
    const partWithInspections = {
      ...part.toJSON(),
      inspections: inspections || []
    };

    res.json(partWithInspections);
  } catch (error) {
    console.error('Error fetching part:', error);
    res.status(500).json({ error: error.message });
  }
});

// POST /parts - Create new part
router.post('/', async (req, res) => {
  try {
    const { name, partNumber, description, status, quantity, price, vendorId } = req.body;

    // Validate required fields
    if (!name || !partNumber || !vendorId) {
      return res.status(400).json({ error: 'Name, partNumber, and vendorId are required' });
    }

    const part = await Part.create({
      name,
      partNumber,
      description,
      status,
      quantity,
      price,
      vendorId,
    });

    res.status(201).json(part);
  } catch (error) {
    if (error.name === 'SequelizeUniqueConstraintError') {
      return res.status(400).json({ error: 'Part number already exists' });
    }
    res.status(500).json({ error: error.message });
  }
});

// PUT /parts/:id - Update existing part
router.put('/:id', async (req, res) => {
  try {
    const part = await Part.findByPk(req.params.id);
    
    if (!part) {
      return res.status(404).json({ error: 'Part not found' });
    }

    await part.update(req.body);
    res.json(part);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// DELETE /parts/:id - Delete part
router.delete('/:id', async (req, res) => {
  try {
    const part = await Part.findByPk(req.params.id);
    
    if (!part) {
      return res.status(404).json({ error: 'Part not found' });
    }

    await part.destroy();
    res.status(204).send();
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;