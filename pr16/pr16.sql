-- ============================================================
-- PR16. Arrays, CSV I/O, and Load Verification (SQLite)
-- ============================================================

-- Setup (re-creating base tables for the assignment)
DROP TABLE IF EXISTS rentals;
DROP TABLE IF EXISTS tools;
DROP TABLE IF EXISTS clients;

CREATE TABLE clients (
  id      INTEGER PRIMARY KEY,
  name    TEXT NOT NULL,
  phone   TEXT
);

CREATE TABLE tools (
  id            INTEGER PRIMARY KEY,
  name          TEXT NOT NULL UNIQUE,
  category      TEXT NOT NULL,
  price_per_day REAL NOT NULL
);

CREATE TABLE rentals (
  id          INTEGER PRIMARY KEY,
  client_id   INTEGER NOT NULL REFERENCES clients(id),
  tool_id     INTEGER NOT NULL REFERENCES tools(id),
  rent_date   TEXT NOT NULL,
  return_date TEXT,
  deposit     REAL NOT NULL
);

INSERT INTO clients (id, name, phone) VALUES
  (1, 'Иванов Пётр',   '+7 912 000-11-22'),
  (2, 'Смирнова Анна', NULL),
  (3, 'Кузнецов Пётр', '+7 913 111-22-33'),
  (4, 'Орлова Мария',  '+7 914 222-33-44'),
  (5, 'Волков Игорь',  NULL);

INSERT INTO tools (id, name, category, price_per_day) VALUES
  (1, 'Дрель ударная',    'Электроинструмент', 350),
  (2, 'Шуруповёрт',       'Электроинструмент', 280),
  (3, 'Перфоратор',       'Электроинструмент', 420),
  (4, 'Молоток',          'Ручной инструмент', 90),
  (5, 'Стамеска',         'Ручной инструмент', 60),
  (6, 'Рубанок',          'Ручной инструмент', 120),
  (7, 'Уровень лазерный', 'Измерение', 240),
  (8, 'Рулетка',          'Измерение', 40);

INSERT INTO rentals (id, client_id, tool_id, rent_date, return_date, deposit) VALUES
  (1, 1, 1, '2026-10-05', '2026-10-09', 1000),
  (2, 2, 4, '2026-10-12', '2026-10-14', 300),
  (3, 3, 3, '2026-10-18', '2026-10-25', 1200),
  (4, 1, 6, '2026-10-20', '2026-10-27', 400),
  (5, 4, 2, '2026-11-02', NULL,         800),
  (6, 5, 7, '2026-11-05', NULL,         600),
  (7, 2, 8, '2026-11-08', '2026-11-10', 150),
  (8, 3, 1, '2026-11-12', NULL,         1000);

-- ============================================================
-- Part 1. Multi-row VALUES
-- ============================================================
SELECT COUNT(*) FROM clients; -- 5

INSERT INTO clients (id, name, phone) VALUES
  (6, 'Фёдорова Ольга', '+7 915 333-44-55'),
  (7, 'Морозов Данил',  NULL),
  (8, 'Николаева Вера', '+7 916 444-55-66');

SELECT COUNT(*) FROM clients; -- 8

-- Intentional error: 3 values for 2 columns
INSERT INTO clients (id, name) VALUES (9, 'Тестов Тест', '+7 900 000-00-00');
-- SQLite error: 3 values for 2 columns. Table remains at 8 rows.

-- My batch of new rentals (some return_date are NULL)
INSERT INTO rentals (id, client_id, tool_id, rent_date, return_date, deposit) VALUES
  (9, 1, 8, '2026-11-15', NULL, 150),
  (10, 2, 5, '2026-11-16', '2026-11-17', 60),
  (11, 4, 6, '2026-11-18', NULL, 120),
  (12, 5, 4, '2026-11-19', '2026-11-20', 90);

SELECT COUNT(*), SUM(deposit) FROM rentals; -- 12 | 7950.0

-- ============================================================
-- Part 2. INSERT ... SELECT
-- ============================================================
CREATE TABLE rentals_archive (
  id          INTEGER PRIMARY KEY,
  client_id   INTEGER NOT NULL,
  tool_id     INTEGER NOT NULL,
  rent_date   TEXT NOT NULL,
  return_date TEXT,
  deposit     REAL NOT NULL
);

INSERT INTO rentals_archive (id, client_id, tool_id, rent_date, return_date, deposit)
SELECT id, client_id, tool_id, rent_date, return_date, deposit
FROM rentals
WHERE return_date IS NOT NULL AND rent_date < '2026-11-01';

SELECT COUNT(*), SUM(deposit) FROM rentals_archive; -- 4 | 2900.0

DELETE FROM rentals
WHERE return_date IS NOT NULL AND rent_date < '2026-11-01';

SELECT COUNT(*), SUM(deposit) FROM rentals; -- 8 | 5050.0

-- Verification: 5050.0 + 2900.0 = 7950.0

-- Insert tools via SELECT ... UNION ALL
INSERT INTO tools (id, name, category, price_per_day)
  SELECT 9,  'Степлер строительный', 'Ручной инструмент', 110
  UNION ALL
  SELECT 10, 'Тестер напряжения',     'Электроинструмент', 150;

SELECT COUNT(*) FROM tools; -- 10

-- ============================================================
-- Part 3. Temporary Table (Staging)
-- ============================================================
CREATE TEMP TABLE stage_tools (
  s_id          INTEGER PRIMARY KEY,
  t_id          INTEGER NOT NULL,
  name          TEXT NOT NULL,
  category      TEXT NOT NULL,
  price_per_day REAL NOT NULL
);

INSERT INTO stage_tools (s_id, t_id, name, category, price_per_day) VALUES
  (1, 11, 'Ключ разводной', 'Ручной инструмент', 70),
  (2, 12, 'Ключ разводной', 'Ручной инструмент', 70),
  (3, 13, 'Генератор',      'Электроинструмент', 900),
  (4, 14, 'Лобзик',         'Электроинструмент', 310),
  (5, 15, 'Перфоратор',     'Электроинструмент', 420),
  (6, 16, 'Теодолит',       'Измерение', 500);

SELECT COUNT(*), COUNT(DISTINCT name) FROM stage_tools; -- 6 | 5

SELECT name, COUNT(*) AS n FROM stage_tools
GROUP BY name HAVING COUNT(*) > 1; -- 'Ключ разводной' | 2

-- Failing insert (UNIQUE constraint)
INSERT INTO tools (id, name, category, price_per_day)
SELECT t_id, name, category, price_per_day
FROM stage_tools
WHERE name NOT IN (SELECT name FROM tools);
-- Error: UNIQUE constraint failed: tools.name

-- Clean duplicate and insert again
DELETE FROM stage_tools WHERE s_id = 2;

INSERT INTO tools (id, name, category, price_per_day)
SELECT t_id, name, category, price_per_day
FROM stage_tools
WHERE name NOT IN (SELECT name FROM tools);

SELECT COUNT(*) FROM tools; -- 16

-- ============================================================
-- Part 4. CSV I/O
-- ============================================================
-- Note: Use CLI commands for export/import in SQLite:
-- .mode csv
-- .headers on
-- .once tools.csv
-- SELECT id, name, category, price_per_day FROM tools ORDER BY id;

CREATE TABLE tools_import (
  id            INTEGER PRIMARY KEY,
  name          TEXT NOT NULL,
  category      TEXT NOT NULL,
  price_per_day REAL NOT NULL
);

-- CLI: .import --csv --skip 1 tools.csv tools_import

-- Verification after import
SELECT COUNT(*), SUM(price_per_day) FROM tools;        -- 16 | 5950.0 (actual value after Part 3)
SELECT COUNT(*), SUM(price_per_day) FROM tools_import; -- 16 | 5950.0

-- Test importing without skipping header (will fail due to datatype mismatch)
-- CLI: .import --csv tools.csv tools_import
-- Error: INSERT failed: datatype mismatch

-- ============================================================
-- Part 5. Aggregate Functions
-- ============================================================
SELECT COUNT(*), SUM(deposit), AVG(deposit), MIN(deposit), MAX(deposit)
FROM rentals; -- 8 | 5050.0 | 631.25 | 150.0 | 1000.0

-- Cross-check rentals + archive
SELECT (SELECT COUNT(*) FROM rentals) + (SELECT COUNT(*) FROM rentals_archive) AS rows_total,
       (SELECT SUM(deposit) FROM rentals) + (SELECT SUM(deposit) FROM rentals_archive) AS deposit_total;
-- 12 | 7950.0

-- COUNT(*) vs COUNT(phone)
SELECT COUNT(*) AS total, COUNT(phone) AS with_phone FROM clients; -- 8 | 5

-- GROUP BY category in tools
SELECT category,
       COUNT(*) AS positions,
       ROUND(AVG(price_per_day), 2) AS avg_price,
       MIN(price_per_day) AS min_price,
       MAX(price_per_day) AS max_price
FROM tools
GROUP BY category
ORDER BY category;