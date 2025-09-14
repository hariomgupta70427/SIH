#!/usr/bin/env node
/**
 * Mock Blockchain API for demo purposes
 * Provides blockchain verification endpoints without actual blockchain
 */

const express = require('express');
const cors = require('cors');

const app = express();
const PORT = process.env.BLOCKCHAIN_PORT || 6000;

// Middleware
app.use(cors());
app.use(express.json());

// Mock blockchain data
const mockTransactions = {
  'P-001': { verified: true, tx: '0xDEMO001', block: 12345, timestamp: '2024-01-15T10:30:00Z' },
  'P-002': { verified: true, tx: '0xDEMO002', block: 12346, timestamp: '2024-01-16T11:45:00Z' },
  'P-003': { verified: false, tx: null, block: null, timestamp: null },
  'P-004': { verified: true, tx: '0xDEMO004', block: 12348, timestamp: '2024-01-18T09:15:00Z' },
  'P-005': { verified: true, tx: '0xDEMO005', block: 12349, timestamp: '2024-01-19T14:20:00Z' }
};

// Health check
app.get('/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    service: 'Mock Blockchain API',
    timestamp: new Date().toISOString() 
  });
});

// Verify part on blockchain
app.get('/verify/:partId', (req, res) => {
  const { partId } = req.params;
  
  // Check if we have mock data for this part
  if (mockTransactions[partId]) {
    res.json(mockTransactions[partId]);
  } else {
    // Generate deterministic response for unknown parts
    const verified = partId.includes('P-') && !partId.includes('P-003'); // P-003 is always unverified
    res.json({
      verified,
      tx: verified ? `0xDEMO${partId.replace('P-', '')}` : null,
      block: verified ? Math.floor(Math.random() * 10000) + 10000 : null,
      timestamp: verified ? new Date().toISOString() : null
    });
  }
});

// Record part on blockchain (mock)
app.post('/record', (req, res) => {
  const { partId, metadata } = req.body;
  
  if (!partId) {
    return res.status(400).json({ error: 'Part ID is required' });
  }
  
  // Mock successful recording
  const txHash = `0xDEMO${Date.now()}`;
  const blockNumber = Math.floor(Math.random() * 10000) + 10000;
  
  res.json({
    success: true,
    partId,
    transaction: txHash,
    block: blockNumber,
    timestamp: new Date().toISOString(),
    gasUsed: '21000',
    status: 'confirmed'
  });
});

// Get transaction details
app.get('/transaction/:txHash', (req, res) => {
  const { txHash } = req.params;
  
  res.json({
    hash: txHash,
    block: Math.floor(Math.random() * 10000) + 10000,
    timestamp: new Date().toISOString(),
    status: 'confirmed',
    gasUsed: '21000',
    from: '0xMockSender123',
    to: '0xMockContract456'
  });
});

// Error handling
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Internal server error' });
});

// Start server
app.listen(PORT, () => {
  console.log(`🔗 Mock Blockchain API running on http://localhost:${PORT}`);
  console.log(`📋 Available endpoints:`);
  console.log(`   GET  /health`);
  console.log(`   GET  /verify/:partId`);
  console.log(`   POST /record`);
  console.log(`   GET  /transaction/:txHash`);
});

module.exports = app;