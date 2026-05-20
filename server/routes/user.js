const express = require('express');
const router = express.Router();
const db = require('../database');

router.post('/', (req, res) => {
  const {
    age, smoking_years, cigarettes_per_day, product_type,
    does_exercise, morning_cough, shortness_of_breath, stress_smoker,
    price_per_cigarette, biological_sex, height_cm, age_first_cigarette,
    exercise_level, selected_product_id, fagerstrom_score,
    baseline_cough, baseline_breathlessness,
  } = req.body;

  const stmt = db.prepare(`
    INSERT INTO user_profile (
      age, smoking_years, cigarettes_per_day, product_type,
      does_exercise, morning_cough, shortness_of_breath, stress_smoker,
      price_per_cigarette, biological_sex, height_cm, age_first_cigarette,
      exercise_level, selected_product_id, fagerstrom_score,
      baseline_cough, baseline_breathlessness
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
  `);

  const result = stmt.run(
    age, smoking_years, cigarettes_per_day, product_type,
    does_exercise ? 1 : 0, morning_cough ? 1 : 0,
    shortness_of_breath ? 1 : 0, stress_smoker ? 1 : 0,
    price_per_cigarette || 0.30,
    biological_sex || 'male', height_cm || 175, age_first_cigarette || 16,
    exercise_level ?? 1, selected_product_id || null, fagerstrom_score || 0,
    baseline_cough || 1, baseline_breathlessness || 1,
  );
  res.json({ id: result.lastInsertRowid });
});

router.get('/:id', (req, res) => {
  const user = db.prepare('SELECT * FROM user_profile WHERE id = ?').get(req.params.id);
  if (!user) return res.status(404).json({ error: 'User not found' });
  res.json(user);
});

router.put('/:id', (req, res) => {
  const {
    age, smoking_years, cigarettes_per_day, product_type,
    does_exercise, morning_cough, shortness_of_breath, stress_smoker,
    price_per_cigarette, biological_sex, height_cm, age_first_cigarette,
    exercise_level, selected_product_id, fagerstrom_score,
    baseline_cough, baseline_breathlessness,
  } = req.body;

  db.prepare(`
    UPDATE user_profile SET
      age=?, smoking_years=?, cigarettes_per_day=?, product_type=?,
      does_exercise=?, morning_cough=?, shortness_of_breath=?, stress_smoker=?,
      price_per_cigarette=?, biological_sex=?, height_cm=?, age_first_cigarette=?,
      exercise_level=?, selected_product_id=?, fagerstrom_score=?,
      baseline_cough=?, baseline_breathlessness=?,
      updated_at=CURRENT_TIMESTAMP
    WHERE id=?
  `).run(
    age, smoking_years, cigarettes_per_day, product_type,
    does_exercise ? 1 : 0, morning_cough ? 1 : 0,
    shortness_of_breath ? 1 : 0, stress_smoker ? 1 : 0,
    price_per_cigarette || 0.30,
    biological_sex || 'male', height_cm || 175, age_first_cigarette || 16,
    exercise_level ?? 1, selected_product_id || null, fagerstrom_score || 0,
    baseline_cough || 1, baseline_breathlessness || 1,
    req.params.id,
  );
  res.json({ success: true });
});

module.exports = router;
