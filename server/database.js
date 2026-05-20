const Database = require('better-sqlite3');
const path = require('path');

const db = new Database(path.join(__dirname, 'breath.db'));

db.pragma('journal_mode = WAL');

db.exec(`
  CREATE TABLE IF NOT EXISTS user_profile (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    age INTEGER NOT NULL,
    smoking_years INTEGER NOT NULL,
    cigarettes_per_day REAL NOT NULL,
    product_type TEXT NOT NULL CHECK(product_type IN ('cigarette', 'iqos', 'rolled', 'mixed')),
    does_exercise BOOLEAN DEFAULT 0,
    morning_cough BOOLEAN DEFAULT 0,
    shortness_of_breath BOOLEAN DEFAULT 0,
    stress_smoker BOOLEAN DEFAULT 0,
    price_per_cigarette REAL DEFAULT 0.30,
    biological_sex TEXT DEFAULT 'male',
    height_cm INTEGER DEFAULT 175,
    age_first_cigarette INTEGER DEFAULT 16,
    exercise_level INTEGER DEFAULT 1,
    selected_product_id INTEGER,
    fagerstrom_score INTEGER DEFAULT 0,
    baseline_cough INTEGER DEFAULT 1,
    baseline_breathlessness INTEGER DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
  );

  CREATE TABLE IF NOT EXISTS cigarette_logs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    smoked_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    context TEXT CHECK(context IN ('stress', 'social', 'boredom', 'after_coffee', 'after_meal', 'other', NULL)),
    FOREIGN KEY (user_id) REFERENCES user_profile(id)
  );

  CREATE TABLE IF NOT EXISTS weekly_checkins (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    cough_level INTEGER CHECK(cough_level BETWEEN 1 AND 5),
    breath_level INTEGER CHECK(breath_level BETWEEN 1 AND 5),
    phlegm_level INTEGER CHECK(phlegm_level BETWEEN 1 AND 5),
    sleep_quality INTEGER CHECK(sleep_quality BETWEEN 1 AND 5),
    energy_level INTEGER CHECK(energy_level BETWEEN 1 AND 5),
    checked_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES user_profile(id)
  );

  CREATE TABLE IF NOT EXISTS lung_scores (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    score REAL NOT NULL,
    pack_years REAL NOT NULL,
    estimated_fev1_decline REAL NOT NULL,
    calculated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES user_profile(id)
  );

  CREATE TABLE IF NOT EXISTS tobacco_products (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    brand TEXT NOT NULL,
    category TEXT NOT NULL CHECK(category IN ('cigarette', 'heated', 'rolling')),
    pack_size INTEGER NOT NULL DEFAULT 20,
    pack_price REAL NOT NULL,
    price_per_unit REAL NOT NULL,
    nicotine_mg REAL,
    tar_mg REAL,
    last_updated DATE DEFAULT CURRENT_DATE
  );
`);

// Safe migration: add new columns to existing user_profile tables
const columnMigrations = [
  { name: 'biological_sex', sql: "ALTER TABLE user_profile ADD COLUMN biological_sex TEXT DEFAULT 'male'" },
  { name: 'height_cm', sql: 'ALTER TABLE user_profile ADD COLUMN height_cm INTEGER DEFAULT 175' },
  { name: 'age_first_cigarette', sql: 'ALTER TABLE user_profile ADD COLUMN age_first_cigarette INTEGER DEFAULT 16' },
  { name: 'exercise_level', sql: 'ALTER TABLE user_profile ADD COLUMN exercise_level INTEGER DEFAULT 1' },
  { name: 'selected_product_id', sql: 'ALTER TABLE user_profile ADD COLUMN selected_product_id INTEGER' },
  { name: 'fagerstrom_score', sql: 'ALTER TABLE user_profile ADD COLUMN fagerstrom_score INTEGER DEFAULT 0' },
  { name: 'baseline_cough', sql: 'ALTER TABLE user_profile ADD COLUMN baseline_cough INTEGER DEFAULT 1' },
  { name: 'baseline_breathlessness', sql: 'ALTER TABLE user_profile ADD COLUMN baseline_breathlessness INTEGER DEFAULT 1' },
];

const existingColumns = db.prepare("PRAGMA table_info(user_profile)").all().map(c => c.name);
for (const migration of columnMigrations) {
  if (!existingColumns.includes(migration.name)) {
    try {
      db.exec(migration.sql);
    } catch (e) {
      // Column may already exist from CREATE TABLE
    }
  }
}

// Seed tobacco products if table is empty
const productCount = db.prepare('SELECT COUNT(*) as count FROM tobacco_products').get();
if (productCount.count === 0) {
  const products = [
    // CIGARETTES — ADM Italy 2026 prices (pack of 20)
    { brand: 'Marlboro Gold',        category: 'cigarette', pack_price: 6.80, nicotine_mg: 1.2, tar_mg: 10 },
    { brand: 'Marlboro Rosse',       category: 'cigarette', pack_price: 6.80, nicotine_mg: 1.3, tar_mg: 10 },
    { brand: 'Merit SSL',            category: 'cigarette', pack_price: 6.80, nicotine_mg: 1.0, tar_mg: 8 },
    { brand: 'Muratti Ambassador',   category: 'cigarette', pack_price: 6.80, nicotine_mg: 1.2, tar_mg: 10 },
    { brand: 'Camel',                category: 'cigarette', pack_price: 6.30, nicotine_mg: 1.2, tar_mg: 10 },
    { brand: 'Lucky Strike',         category: 'cigarette', pack_price: 6.20, nicotine_mg: 1.3, tar_mg: 10 },
    { brand: 'Philip Morris',        category: 'cigarette', pack_price: 6.00, nicotine_mg: 1.1, tar_mg: 9 },
    { brand: 'Chesterfield',         category: 'cigarette', pack_price: 5.80, nicotine_mg: 1.1, tar_mg: 9 },
    { brand: 'Winston',              category: 'cigarette', pack_price: 5.80, nicotine_mg: 1.2, tar_mg: 10 },
    { brand: 'Corset',               category: 'cigarette', pack_price: 5.70, nicotine_mg: 1.0, tar_mg: 9 },
    { brand: 'Diana',                category: 'cigarette', pack_price: 5.70, nicotine_mg: 1.1, tar_mg: 9 },
    { brand: 'Pall Mall',            category: 'cigarette', pack_price: 5.60, nicotine_mg: 1.1, tar_mg: 9 },
    { brand: 'The King',             category: 'cigarette', pack_price: 5.40, nicotine_mg: 1.0, tar_mg: 9 },
    // HEATED TOBACCO — no combustion: tar ~0
    { brand: 'HEETS',                category: 'heated', pack_price: 5.50, nicotine_mg: 1.1, tar_mg: 0 },
    { brand: 'TEREA (IQOS Iluma)',   category: 'heated', pack_price: 5.50, nicotine_mg: 1.1, tar_mg: 0 },
    { brand: 'FIIT (LIL Solid)',     category: 'heated', pack_price: 4.70, nicotine_mg: 1.0, tar_mg: 0 },
    { brand: 'GLO Neo Sticks',       category: 'heated', pack_price: 4.30, nicotine_mg: 1.0, tar_mg: 0 },
    { brand: 'PULZE ID',             category: 'heated', pack_price: 3.80, nicotine_mg: 1.0, tar_mg: 0 },
    // ROLLING — per rolled cigarette equivalent
    { brand: 'Tabacco rollato (generico)', category: 'rolling', pack_price: 5.00, nicotine_mg: 1.7, tar_mg: 13 },
  ];

  const insert = db.prepare(
    'INSERT INTO tobacco_products (brand, category, pack_size, pack_price, price_per_unit, nicotine_mg, tar_mg) VALUES (?, ?, 20, ?, ?, ?, ?)'
  );

  const seedAll = db.transaction(() => {
    for (const p of products) {
      insert.run(p.brand, p.category, p.pack_price, +(p.pack_price / 20).toFixed(4), p.nicotine_mg, p.tar_mg);
    }
  });
  seedAll();
}

module.exports = db;
