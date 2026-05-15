const express = require('express');
const router = express.Router();
const { getPool } = require('../db');

// GET /api/overview
router.get('/', async (req, res) => {
  try {
    const pool = await getPool();

    const usersResult = await pool.request().query('SELECT COUNT(*) as totalUsers FROM Users');
    const walletsResult = await pool.request().query(
      'SELECT COUNT(*) as totalWallets, SUM(balance) as totalVolume, AVG(balance) as avgBalance FROM Wallets'
    );
    const txnResult = await pool.request().query('SELECT COUNT(*) as totalTransactions FROM Transactions');

    res.json({
      totalUsers: usersResult.recordset[0].totalUsers,
      totalWallets: walletsResult.recordset[0].totalWallets,
      totalVolume: parseFloat(walletsResult.recordset[0].totalVolume) || 0,
      avgBalance: parseFloat(walletsResult.recordset[0].avgBalance) || 0,
      totalTransactions: txnResult.recordset[0].totalTransactions
    });
  } catch (err) {
    console.error('/api/overview error:', err.message);
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
