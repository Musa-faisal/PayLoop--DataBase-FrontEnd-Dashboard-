const express = require('express');
const router = express.Router();
const { getPool } = require('../db');

// GET /api/transactions — last 50 from ShowTransactions
router.get('/', async (req, res) => {
  try {
    const pool = await getPool();
    const result = await pool.request().query(
      'SELECT TOP 50 * FROM ShowTransactions ORDER BY txn_date DESC'
    );
    res.json(result.recordset);
  } catch (err) {
    console.error('/api/transactions error:', err.message);
    res.status(500).json({ error: err.message });
  }
});

// GET /api/transactions/summary — grouped by txn_type
router.get('/summary', async (req, res) => {
  try {
    const pool = await getPool();
    const result = await pool.request().query(`
      SELECT
        txn_type,
        COUNT(txn_id) as txn_count,
        SUM(amount)   as total_amount,
        AVG(amount)   as avg_amount
      FROM Transactions
      GROUP BY txn_type
    `);
    res.json(result.recordset);
  } catch (err) {
    console.error('/api/transactions/summary error:', err.message);
    res.status(500).json({ error: err.message });
  }
});

// GET /api/transactions/monthly — monthly totals
router.get('/monthly', async (req, res) => {
  try {
    const pool = await getPool();
    const result = await pool.request().query(`
      WITH MonthlyTotals AS (
        SELECT
          YEAR(txn_date)  AS year,
          MONTH(txn_date) AS month,
          SUM(amount)     AS total_amount,
          COUNT(txn_id)   AS txn_count
        FROM Transactions
        GROUP BY YEAR(txn_date), MONTH(txn_date)
      )
      SELECT * FROM MonthlyTotals
      ORDER BY year, month
    `);
    res.json(result.recordset);
  } catch (err) {
    console.error('/api/transactions/monthly error:', err.message);
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
