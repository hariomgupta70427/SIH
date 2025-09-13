const express = require('express');
const { Vendor, Part } = require('../models');
const router = express.Router();

// GET /vendors - List all vendors
router.get('/', async (req, res) => {
  try {
    const { status, limit = 50, offset = 0 } = req.query;
    const where = {};
    
    if (status) where.status = status;

    const vendors = await Vendor.findAll({
      where,
      include: [{ model: Part, attributes: ['id', 'name', 'status'] }],
      limit: parseInt(limit),
      offset: parseInt(offset),
    });

    res.json(vendors);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// GET /vendors/:id - Get specific vendor
router.get('/:id', async (req, res) => {
  try {
    const vendor = await Vendor.findByPk(req.params.id, {
      include: [{ model: Part }],
    });

    if (!vendor) {
      return res.status(404).json({ error: 'Vendor not found' });
    }

    res.json(vendor);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// POST /vendors - Create new vendor
router.post('/', async (req, res) => {
  try {
    const { name, email, phone, address, status } = req.body;

    if (!name) {
      return res.status(400).json({ error: 'Name is required' });
    }

    const vendor = await Vendor.create({
      name,
      email,
      phone,
      address,
      status,
    });

    res.status(201).json(vendor);
  } catch (error) {
    if (error.name === 'SequelizeUniqueConstraintError') {
      return res.status(400).json({ error: 'Email already exists' });
    }
    res.status(500).json({ error: error.message });
  }
});

// PUT /vendors/:id - Update vendor
router.put('/:id', async (req, res) => {
  try {
    const vendor = await Vendor.findByPk(req.params.id);
    
    if (!vendor) {
      return res.status(404).json({ error: 'Vendor not found' });
    }

    await vendor.update(req.body);
    res.json(vendor);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// DELETE /vendors/:id - Delete vendor
router.delete('/:id', async (req, res) => {
  try {
    const vendor = await Vendor.findByPk(req.params.id);
    
    if (!vendor) {
      return res.status(404).json({ error: 'Vendor not found' });
    }

    await vendor.destroy();
    res.status(204).send();
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;