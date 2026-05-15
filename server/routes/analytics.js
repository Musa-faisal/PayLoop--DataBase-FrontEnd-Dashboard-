const express = require('express');
const router = express.Router();
const { getPool } = require('../db');

// GET /api/analytics/cities
router.get('/cities', async (req, res) => {
  try {
    const pool = await getPool();
    const result = await pool.request().query(
      'SELECT * FROM CityTransactions ORDER BY transaction_month, transaction_volume DESC'
    );
    res.json(result.recordset);
  } catch (err) {
    console.error('/api/analytics/cities error:', err.message);
    res.status(500).json({ error: err.message });
  }
});

// GET /api/analytics/fraud
router.get('/fraud', async (req, res) => {
  try {
    const pool = await getPool();
    const result = await pool.request().query(
      'SELECT * FROM FraudMonitoring ORDER BY amount DESC'
    );
    res.json(result.recordset);
  } catch (err) {
    console.error('/api/analytics/fraud error:', err.message);
    res.status(500).json({ error: err.message });
  }
});

// GET /api/audit
router.get('/audit', async (req, res) => {
  try {
    const pool = await getPool();
    const result = await pool.request().query(
      'SELECT TOP 20 * FROM AuditLog ORDER BY log_date DESC'
    );
    res.json(result.recordset);
  } catch (err) {
    console.error('/api/audit error:', err.message);
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
