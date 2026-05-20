const express = require('express');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

app.use('/api/user', require('./routes/user'));
app.use('/api/logs', require('./routes/logs'));
app.use('/api/report', require('./routes/reports'));
app.use('/api/checkin', require('./routes/checkin'));
app.use('/api/products', require('./routes/products'));

app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Breath server running on port ${PORT}`);
});
