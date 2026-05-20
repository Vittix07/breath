const express = require('express');
const router = express.Router();
const db = require('../database');

router.get('/', (req, res) => {
  const products = db.prepare('SELECT * FROM tobacco_products ORDER BY category, brand').all();
  const grouped = {};
  for (const p of products) {
    if (!grouped[p.category]) grouped[p.category] = [];
    grouped[p.category].push(p);
  }
  res.json({ products, grouped });
});

router.get('/:id', (req, res) => {
  const product = db.prepare('SELECT * FROM tobacco_products WHERE id = ?').get(req.params.id);
  if (!product) return res.status(404).json({ error: 'Product not found' });
  res.json(product);
});

module.exports = router;
