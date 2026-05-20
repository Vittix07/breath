const express = require('express');
const router = express.Router();
const db = require('../database');

// --- Medical constants (mirrored from Dart) ---
const BASE_DECLINE_MALE = 31.0;
const BASE_DECLINE_FEMALE = 27.0;
const DECLINE_PER_CIGARETTE = 2.2;
const MAX_SMOKING_DECLINE = 54.0;
const PEAK_AGE = 22;
const DECLINE_START_AGE = 25;
const EX_SMOKER_DECLINE = 35.0;

function predictedFEV1(sex, age, heightCm) {
  if (sex === 'male') {
    return (-0.0244 * age) + (0.0436 * heightCm) - 3.84;
  }
  return (-0.0210 * age) + (0.0342 * heightCm) - 2.79;
}

function computeModifierFactor(user) {
  let factor = 1.0;
  const exerciseLevel = user.exercise_level ?? 1;
  if (exerciseLevel === 0) factor += 0.10;
  else if (exerciseLevel === 2) factor -= 0.08;
  else if (exerciseLevel === 3) factor -= 0.15;

  const ageFirst = user.age_first_cigarette ?? 16;
  if (ageFirst < 16) factor += 0.12;
  else if (ageFirst < 18) factor += 0.06;

  const productType = user.product_type || 'cigarette';
  if (productType === 'rolled') factor += 0.08;
  else if (productType === 'iqos') factor -= 0.25;
  else if (productType === 'mixed') factor += 0.04;

  if ((user.fagerstrom_score ?? 0) >= 7) factor += 0.05;
  if ((user.baseline_cough ?? 1) >= 4) factor += 0.06;
  if ((user.baseline_breathlessness ?? 1) >= 4) factor += 0.08;

  return Math.min(1.6, Math.max(0.6, factor));
}

function calculateLungScore(user) {
  const sex = user.biological_sex || 'male';
  const heightCm = user.height_cm || 175;
  const baseDecline = sex === 'male' ? BASE_DECLINE_MALE : BASE_DECLINE_FEMALE;
  const peakFEV1ml = predictedFEV1(sex, PEAK_AGE, heightCm) * 1000;
  const declineYears = Math.max(0, Math.min(100, user.age - DECLINE_START_AGE));
  const naturalDecline = baseDecline * declineYears;
  const modifierFactor = computeModifierFactor(user);
  const smokingDeclineAnnual = Math.min(MAX_SMOKING_DECLINE, user.cigarettes_per_day * DECLINE_PER_CIGARETTE);
  const smokingDeclineTotal = smokingDeclineAnnual * user.smoking_years * modifierFactor;
  const expectedFEV1 = peakFEV1ml - naturalDecline;
  const currentFEV1 = peakFEV1ml - naturalDecline - smokingDeclineTotal;
  const score = (currentFEV1 / expectedFEV1) * 100;
  return Math.round(Math.min(100, Math.max(0, score)));
}

router.get('/:userId/summary', (req, res) => {
  const userId = req.params.userId;
  const monthLogs = db.prepare(`SELECT COUNT(*) as count FROM cigarette_logs WHERE user_id = ? AND strftime('%Y-%m', smoked_at) = strftime('%Y-%m', 'now')`).get(userId);
  const user = db.prepare('SELECT * FROM user_profile WHERE id = ?').get(userId);
  if (!user) return res.status(404).json({ error: 'User not found' });

  const packYears = (user.cigarettes_per_day / 20) * user.smoking_years;
  const dailyAvg = monthLogs.count / Math.max(new Date().getDate(), 1);

  let product = null;
  if (user.selected_product_id) {
    product = db.prepare('SELECT * FROM tobacco_products WHERE id = ?').get(user.selected_product_id);
  }

  const packPrice = product ? product.pack_price : (user.price_per_cigarette * 20);
  const packsConsumed = Math.floor(monthLogs.count / 20);
  const moneySpent = packsConsumed * packPrice;

  const tarMg = product ? product.tar_mg : 10;
  const nicotineMg = product ? product.nicotine_mg : 1.2;

  res.json({
    cigarettes_this_month: monthLogs.count,
    daily_average: Math.round(dailyAvg * 10) / 10,
    pack_years: Math.round(packYears * 10) / 10,
    money_spent: Math.round(moneySpent * 100) / 100,
    packs_consumed: packsConsumed,
    cigarettes_in_current_pack: monthLogs.count % 20,
    tar_inhaled_grams: Math.round((monthLogs.count * tarMg) / 1000 * 100) / 100,
    nicotine_absorbed_mg: Math.round(monthLogs.count * nicotineMg * 10) / 10,
  });
});

router.get('/:userId/lung-score', (req, res) => {
  const user = db.prepare('SELECT * FROM user_profile WHERE id = ?').get(req.params.userId);
  if (!user) return res.status(404).json({ error: 'User not found' });

  const score = calculateLungScore(user);
  const packYears = (user.cigarettes_per_day / 20) * user.smoking_years;
  const modifierFactor = computeModifierFactor(user);

  res.json({ score, pack_years: packYears, modifier_factor: modifierFactor });
});

router.get('/:userId/projection', (req, res) => {
  const user = db.prepare('SELECT * FROM user_profile WHERE id = ?').get(req.params.userId);
  if (!user) return res.status(404).json({ error: 'User not found' });

  const sex = user.biological_sex || 'male';
  const heightCm = user.height_cm || 175;
  const baseDecline = sex === 'male' ? BASE_DECLINE_MALE : BASE_DECLINE_FEMALE;
  const peakFEV1ml = predictedFEV1(sex, PEAK_AGE, heightCm) * 1000;
  const modifierFactor = computeModifierFactor(user);
  const smokingDeclineAnnual = Math.min(MAX_SMOKING_DECLINE, user.cigarettes_per_day * DECLINE_PER_CIGARETTE) * modifierFactor;

  const declineYears = Math.max(0, user.age - DECLINE_START_AGE);
  const naturalDecline = baseDecline * declineYears;
  const smokingDeclineTotal = Math.min(MAX_SMOKING_DECLINE, user.cigarettes_per_day * DECLINE_PER_CIGARETTE) * user.smoking_years * modifierFactor;

  let fev1Continue = peakFEV1ml - naturalDecline - smokingDeclineTotal;
  let fev1Quit = fev1Continue;

  const points = [];
  for (let futureAge = user.age; futureAge <= user.age + 40; futureAge++) {
    const dy = Math.max(0, Math.min(100, futureAge - DECLINE_START_AGE));
    const nonSmokerFEV1 = peakFEV1ml - (baseDecline * dy);

    points.push({
      age: futureAge,
      non_smoker: Math.max(0, Math.min(100, (nonSmokerFEV1 / peakFEV1ml) * 100)),
      smoker: Math.max(0, Math.min(100, (fev1Continue / peakFEV1ml) * 100)),
      quitter: Math.max(0, Math.min(100, (fev1Quit / peakFEV1ml) * 100)),
    });

    if (futureAge >= DECLINE_START_AGE) {
      fev1Continue -= (baseDecline + smokingDeclineAnnual);
      fev1Quit -= EX_SMOKER_DECLINE;
    }
  }

  res.json(points);
});

router.get('/:userId/patterns', (req, res) => {
  const userId = req.params.userId;
  const contexts = db.prepare(`SELECT context, COUNT(*) as count FROM cigarette_logs WHERE user_id = ? AND context IS NOT NULL GROUP BY context ORDER BY count DESC`).all(userId);
  const hourly = db.prepare(`SELECT strftime('%H', smoked_at) as hour, COUNT(*) as count FROM cigarette_logs WHERE user_id = ? GROUP BY hour ORDER BY count DESC LIMIT 3`).all(userId);
  const weekday = db.prepare(`SELECT strftime('%w', smoked_at) as day, COUNT(*) as count FROM cigarette_logs WHERE user_id = ? GROUP BY day ORDER BY count DESC LIMIT 1`).all(userId);

  res.json({ contexts, peak_hours: hourly, worst_day: weekday[0] || null });
});

module.exports = router;
