-- ============================================================
-- PR15. Variables, Program File, and Tabular Files (SQLite)
-- ============================================================

-- ============================================================
-- Part 1. Variables in an SQL script
-- ============================================================
-- SQLite does not have session variables. A CTE is used as a portable replacement.
WITH max_dep AS (
    SELECT MAX(deposit) AS val FROM rentals
)
SELECT id, tool_id, deposit 
FROM rentals, max_dep 
WHERE deposit = max_dep.val;

-- Check: max deposit = 5000 (value depends on your DB).

-- Second variable: rental count
SELECT COUNT(*) AS total_rentals FROM rentals;

-- ============================================================
-- Part 2. Program file
-- ============================================================
DROP TABLE IF EXISTS demo_tools;
CREATE TABLE demo_tools (
  id            INTEGER PRIMARY KEY,
  name          TEXT NOT NULL,
  category      TEXT NOT NULL,
  price_per_day INTEGER NOT NULL
);

INSERT INTO demo_tools (name, category, price_per_day) VALUES
  ('Молоток слесарный',  'ручной',  90),
  ('Отвертка набор',     'ручной',  60),
  ('Дрель ударная',      'электро', 330),
  ('Перфоратор',         'электро', 390),
  ('Пила циркулярная',   'электро', 330),
  ('Стремянка 3 м',      'высота',  120);

-- Test rerunability: execute this block twice, no errors expected.
SELECT COUNT(*) FROM demo_tools; -- 6
SELECT MIN(price_per_day), MAX(price_per_day) FROM demo_tools; -- 60, 390
SELECT AVG(price_per_day) FROM demo_tools; -- 220.0

DROP TABLE IF EXISTS tools_stage;
CREATE TABLE tools_stage (
  name          TEXT NOT NULL,
  category      TEXT NOT NULL,
  price_per_day INTEGER NOT NULL
);

-- ============================================================
-- Part 3. "Array": CTE and temp table
-- ============================================================
-- Form 1: CTE (verification)
WITH batch_check(name, category, price_per_day) AS (VALUES
  ('Стремянка 2 м',       'высота',  110),
  ('Перфоратор SDS-Plus', 'электро', 420),
  ('Стремянка 3 м',       'высота',  130)
)
SELECT COUNT(*) AS n, MAX(price_per_day) AS top_price FROM batch_check;
-- Expected: 3, 420

-- Form 2: Temp table
CREATE TEMP TABLE batch (name TEXT, category TEXT, price_per_day INTEGER);
INSERT INTO batch VALUES
  ('Стремянка 2 м',       'высота',  110),
  ('Перфоратор SDS-Plus', 'электро', 420),
  ('Стремянка 3 м',       'высота',  130);

-- Update table from array
UPDATE demo_tools
SET price_per_day = (SELECT b.price_per_day FROM batch b WHERE b.name = demo_tools.name)
WHERE EXISTS (SELECT 1 FROM batch b WHERE b.name = demo_tools.name);

-- Check: 1 row updated (Ladder 3m, new price 130).
SELECT name, price_per_day FROM demo_tools WHERE name = 'Стремянка 3 м';

-- ============================================================
-- Part 4. Filling array from tabular file: CSV -> table
-- ============================================================
-- IMPORTANT: For SQLite CLI, run these commands before the SQL query below:
-- .mode csv
-- .import --skip 1 tools_batch.csv tools_stage

-- Verify import
SELECT COUNT(*) FROM tools_stage; -- 3
SELECT * FROM tools_stage ORDER BY name;

-- Transfer to main table with duplicate protection
INSERT INTO demo_tools (name, category, price_per_day)
SELECT s.name, s.category, s.price_per_day
FROM tools_stage s
WHERE NOT EXISTS (
    SELECT 1 FROM demo_tools d WHERE d.name = s.name
);

-- Check: 2 rows inserted (the third already existed).
SELECT COUNT(*) FROM demo_tools; -- 8
SELECT MAX(price_per_day) FROM demo_tools; -- 420

-- ============================================================
-- Part 5. Filling tabular file from array: table -> CSV
-- ============================================================
-- In SQLite CLI, run these commands before the query:
-- .mode csv
-- .titles on
-- .once price_list.csv

SELECT name, category, price_per_day
FROM demo_tools
ORDER BY category, name;

-- Check: price_list.csv should have 9 lines (1 header + 8 data).