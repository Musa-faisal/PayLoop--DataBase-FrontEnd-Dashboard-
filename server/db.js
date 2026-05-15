require('dotenv').config();
const sql = require('mssql');

const config = {
  server: process.env.DB_SERVER,
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  options: {
    encrypt: true,
    trustServerCertificate: true,
    enableArithAbort: true
  },
  port: parseInt(process.env.DB_PORT) || 1433
};

let pool = null;

async function getPool() {
  if (pool) return pool;
  try {
    pool = await sql.connect(config);
    console.log('✅ Connected to SQL Server:', process.env.DB_NAME);
    return pool;
  } catch (err) {
    console.error('❌ DB connection failed:', err.message);
    pool = null;
    throw err;
  }
}

module.exports = { getPool, sql };
