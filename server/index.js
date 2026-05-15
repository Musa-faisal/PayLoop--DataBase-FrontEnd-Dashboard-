require('dotenv').config();
const express = require('express');
const cors = require('cors');
const path = require('path');

const app = express();

app.use(cors());
app.use(express.json());

// Serve static frontend
app.use(express.static(path.join(__dirname, '..', 'client')));

// Mount API routes
app.use('/api/overview', require('./routes/overview'));
app.use('/api/transactions', require('./routes/transactions'));
app.use('/api/merchants', require('./routes/merchants'));
app.use('/api/users', require('./routes/users'));
app.use('/api/analytics', require('./routes/analytics'));

// Fallback: serve index.html for any non-API route
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, '..', 'client', 'index.html'));
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`🚀 PayLoop Dashboard running at http://localhost:${PORT}`);
});
