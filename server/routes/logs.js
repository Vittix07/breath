const express = require('express');
const router = express.Router();
const db = require('../database');

router.post('/', (req, res) => {
  const { user_id, context } = req.body;
  const stmt = db.prepare('INSERT INTO cigarette_logs (user_id, context) VALUES (?, ?)');
  const result = stmt.run(user_id, context || null);
  res.json({ id: result.lastInsertRowid });
});

router.get('/:userId/today', (req, res) => {
  const logs = db.prepare(`SELECT * FROM cigarette_logs WHERE user_id = ? AND date(smoked_at) = date('now')`).all(req.params.userId);
  res.json(logs);
});

router.get('/:userId/week', (req, res) => {
  const logs = db.prepare(`SELECT * FROM cigarette_logs WHERE user_id = ? AND smoked_at >= date('now', '-7 days')`).all(req.params.userId);
  res.json(logs);
});

router.get('/:userId/month', (req, res) => {
  const logs = db.prepare(`SELECT * FROM cigarette_logs WHERE user_id = ? AND strftime('%Y-%m', smoked_at) = strftime('%Y-%m', 'now')`).all(req.params.userId);
  res.json(logs);
});

router.get('/:userId/contexts', (req, res) => {
  const dist = db.prepare(`SELECT context, COUNT(*) as count FROM cigarette_logs WHERE user_id = ? AND strftime('%Y-%m', smoked_at) = strftime('%Y-%m', 'now') GROUP BY context`).all(req.params.userId);
  res.json(dist);
});

module.exports = router;
