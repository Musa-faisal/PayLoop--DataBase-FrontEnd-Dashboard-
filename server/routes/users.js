const express = require('express');
const router = express.Router();
const { getPool } = require('../db');

// GET /api/users/balances — all wallets with user info
router.get('/balances', async (req, res) => {
  try {
    const pool = await getPool();
    const result = await pool.request().query(
      'SELECT * FROM ShowBalances ORDER BY balance DESC'
    );
    res.json(result.recordset);
  } catch (err) {
    console.error('/api/users/balances error:', err.message);
    res.status(500).json({ error: err.message });
  }
});

// GET /api/users/distribution — wallet tiers
router.get('/distribution', async (req, res) => {
  try {
    const pool = await getPool();
    const result = await pool.request().query(`
      SELECT
        balance_tier,
        COUNT(*)      AS user_count,
        SUM(balance)  AS tier_total
      FROM WalletDistribution
      GROUP BY balance_tier
    `);
    res.json(result.recordset);
  } catch (err) {
    console.error('/api/users/distribution error:', err.message);
    res.status(500).json({ error: err.message });
  }
});

// GET /api/users/spending — top spenders (debit + transfer_out)
router.get('/spending', async (req, res) => {
  try {
    const pool = await getPool();
    const result = await pool.request().query(`
      SELECT
        u.name,
        u.email,
        u.city,
        SUM(t.amount)   AS total_spent,
        COUNT(t.txn_id) AS txn_count
      FROM Users u
      JOIN Wallets w   ON u.user_id = w.user_id
      JOIN Transactions t ON w.wallet_id = t.wallet_id
      WHERE t.txn_type IN ('debit', 'transfer_out')
      GROUP BY u.user_id, u.name, u.email, u.city
      ORDER BY total_spent DESC
    `);
    res.json(result.recordset);
  } catch (err) {
    console.error('/api/users/spending error:', err.message);
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
