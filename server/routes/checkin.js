const express = require('express');
const router = express.Router();
const db = require('../database');

router.post('/', (req, res) => {
  const { user_id, cough_level, breath_level, phlegm_level, sleep_quality, energy_level } = req.body;
  const stmt = db.prepare('INSERT INTO weekly_checkins (user_id, cough_level, breath_level, phlegm_level, sleep_quality, energy_level) VALUES (?, ?, ?, ?, ?, ?)');
  const result = stmt.run(user_id, cough_level, breath_level, phlegm_level, sleep_quality, energy_level);
  res.json({ id: result.lastInsertRowid });
});

router.get('/:userId/latest', (req, res) => {
  const checkin = db.prepare('SELECT * FROM weekly_checkins WHERE user_id = ? ORDER BY checked_at DESC LIMIT 1').get(req.params.userId);
  res.json(checkin || null);
});

module.exports = router;
