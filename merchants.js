const express = require('express');
const router = express.Router();
const { getPool } = require('../db');

// GET /api/merchants — all merchants ordered by revenue
router.get('/', async (req, res) => {
  try {
    const pool = await getPool();
    const result = await pool.request().query(
      'SELECT * FROM MerchantTotals ORDER BY total_received DESC'
    );
    res.json(result.recordset);
  } catch (err) {
    console.error('/api/merchants error:', err.message);
    res.status(500).json({ error: err.message });
  }
});

// GET /api/merchants/categories — revenue by category
router.get('/categories', async (req, res) => {
  try {
    const pool = await getPool();
    const result = await pool.request().query(`
      WITH CategoryPerformance AS (
        SELECT
          m.category,
          COUNT(mp.payment_id)  AS payment_count,
          SUM(mp.amount)        AS total_value
        FROM Merchants m
        JOIN MerchantPayments mp ON m.merchant_id = mp.merchant_id
        GROUP BY m.category
      )
      SELECT * FROM CategoryPerformance
      ORDER BY total_value DESC
    `);
    res.json(result.recordset);
  } catch (err) {
    console.error('/api/merchants/categories error:', err.message);
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
