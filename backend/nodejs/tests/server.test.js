const request = require('supertest');
const { app } = require('../server');

describe('Server Health', () => {
  test('Health check endpoint', async () => {
    const response = await request(app)
      .get('/health')
      .expect(200);
    
    expect(response.body.status).toBe('healthy');
    expect(response.body.version).toBeDefined();
    expect(response.body.node).toBeDefined();
  });
  
  test('Dashboard route exists', async () => {
    await request(app)
      .get('/dashboard')
      .expect(200);
  });
});