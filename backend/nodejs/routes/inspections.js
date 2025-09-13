const express = require('express');
const { Inspection, Part } = require('../models');
const router = express.Router();

// GET /inspections - List all inspections
router.get('/', async (req, res) => {
  try {
    const { status, partId, limit = 50, offset = 0 } = req.query;
    const where = {};
    
    if (status) where.status = status;
    if (partId) where.partId = partId;

    const inspections = await Inspection.findAll({
      where,
      include: [{ model: Part, attributes: ['name', 'partNumber'] }],
      limit: parseInt(limit),
      offset: parseInt(offset),
      order: [['inspectionDate', 'DESC']],
    });

    res.json(inspections);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// GET /inspections/:id - Get specific inspection
router.get('/:id', async (req, res) => {
  try {
    const inspection = await Inspection.findByPk(req.params.id, {
      include: [{ model: Part }],
    });

    if (!inspection) {
      return res.status(404).json({ error: 'Inspection not found' });
    }

    res.json(inspection);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// POST /inspections - Create new inspection
router.post('/', async (req, res) => {
  try {
    const { partId, inspectorName, status, notes, score } = req.body;

    if (!partId || !inspectorName || !status) {
      return res.status(400).json({ 
        error: 'partId, inspectorName, and status are required' 
      });
    }

    const inspection = await Inspection.create({
      partId,
      inspectorName,
      status,
      notes,
      score,
    });

    res.status(201).json(inspection);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// PUT /inspections/:id - Update inspection
router.put('/:id', async (req, res) => {
  try {
    const inspection = await Inspection.findByPk(req.params.id);
    
    if (!inspection) {
      return res.status(404).json({ error: 'Inspection not found' });
    }

    await inspection.update(req.body);
    res.json(inspection);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// DELETE /inspections/:id - Delete inspection
router.delete('/:id', async (req, res) => {
  try {
    const inspection = await Inspection.findByPk(req.params.id);
    
    if (!inspection) {
      return res.status(404).json({ error: 'Inspection not found' });
    }

    await inspection.destroy();
    res.status(204).send();
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;