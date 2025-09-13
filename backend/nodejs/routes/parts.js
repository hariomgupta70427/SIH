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

// GET /parts/:id - Get specific part by ID
router.get('/:id', async (req, res) => {
  try {
    const part = await Part.findByPk(req.params.id, {
      include: [{ model: Vendor }],
    });

    if (!part) {
      return res.status(404).json({ error: 'Part not found' });
    }

    res.json(part);
  } catch (error) {
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