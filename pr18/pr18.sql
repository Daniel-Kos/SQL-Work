-- ============================================================
-- PR18. Working and System Windows. Adding Controls.
-- Script for SQLite. Execute sections top to bottom.
-- ============================================================

-- ============================================================
-- PART 1: Object Explorer (Query to system catalog)
-- ============================================================
-- This query emulates what the Object Explorer shows.
SELECT name, type FROM sqlite_master
WHERE type IN ('table', 'view')
ORDER BY name;
-- Expected output:
-- clients | table
-- rentals | table
-- tools | table

-- Results Grid example: price list sorted descending.
SELECT name, price_per_day FROM tools
ORDER BY price_per_day DESC;
-- Expected output:
-- Перфоратор 250.0
-- Дрель ударная 150.0
-- Шуруповёрт 120.0
-- Пила 80.0
-- Молоток 60.0


-- ============================================================
-- PART 2: Input Field (Query Parameter)
-- ============================================================
-- SQLite uses placeholders like :min_price.
-- The value is supplied by the client, not hardcoded in the query.
SELECT name, price_per_day FROM tools
WHERE price_per_day >= :min_price
ORDER BY price_per_day DESC;

-- Test with min_price = 120 (client supplies value):
-- Result: Перфоратор, Дрель ударная, Шуруповёрт.

-- Test with min_price = 80 (client supplies value):
-- Result: all above + Пила.

-- Parameterized text search (pattern '%Мар%'):
SELECT id, name FROM clients WHERE name LIKE '%Мар%';
-- Result: 2 | Ковалёва Мария

-- If value is not supplied (Python sqlite3 example):
-- ProgrammingError: Incorrect number of bindings supplied.


-- ============================================================
-- PART 3: Drop-down List (Lookup Table + Foreign Key)
-- ============================================================
-- Step 1: Create lookup table and fill with distinct categories.
CREATE TABLE categories (
  id   INTEGER PRIMARY KEY,
  name TEXT NOT NULL UNIQUE
);
INSERT INTO categories (name)
SELECT DISTINCT category FROM tools ORDER BY category;
-- Result: 1 | ручной инструмент, 2 | электроинструмент.

-- Step 2: Prove there is no control yet (free text column).
INSERT INTO tools (id, name, category, price_per_day)
VALUES (6, 'Ножовка', 'электроинструментт', 90);
-- The typo passes silently.
DELETE FROM tools WHERE id = 6;

-- Step 3: Enable control. In SQLite we must recreate the table.
PRAGMA foreign_keys = OFF;
BEGIN;
CREATE TABLE tools_new (
  id            INTEGER PRIMARY KEY,
  name          TEXT NOT NULL,
  category_id   INTEGER NOT NULL REFERENCES categories(id),
  price_per_day REAL NOT NULL
);
INSERT INTO tools_new (id, name, category_id, price_per_day)
SELECT t.id, t.name, c.id, t.price_per_day
FROM tools t JOIN categories c ON c.name = t.category;
DROP TABLE tools;
ALTER TABLE tools_new RENAME TO tools;
COMMIT;
PRAGMA foreign_keys = ON;
PRAGMA foreign_key_check; -- Empty result: all links are valid.

-- Step 4: Prove both directions of control.
-- Insert a value outside the lookup table:
INSERT INTO tools (id, name, category_id, price_per_day)
VALUES (7, 'Гаечный ключ', 3, 90);
-- Error: FOREIGN KEY constraint failed

-- Delete a category that is in use:
DELETE FROM categories WHERE id = 1;
-- Error: FOREIGN KEY constraint failed

-- Insert with a valid category_id (2 is 'электроинструмент'):
INSERT INTO tools (id, name, category_id, price_per_day)
VALUES (7, 'Гаечный ключ', 2, 90); -- Success.

-- Insert a duplicate into the lookup table:
INSERT INTO categories (name) VALUES ('электроинструмент');
-- Error: UNIQUE constraint failed: categories.name

-- Final view of the joined data:
SELECT t.name, c.name AS category, t.price_per_day
FROM tools t JOIN categories c ON t.category_id = c.id
ORDER BY t.price_per_day DESC;


-- ============================================================
-- PART 4: System Windows (Export and Import)
-- ============================================================
-- Export: generate INSERT statements for the tools table.
SELECT 'INSERT INTO tools VALUES (' || id || ', ' || quote(name)
       || ', ' || category_id || ', ' || quote(price_per_day) || ');'
FROM tools ORDER BY id;
-- Expected output:
-- INSERT INTO tools VALUES (1, 'Перфоратор', 2, 250.0);
-- INSERT INTO tools VALUES (2, 'Дрель ударная', 2, 150.0);
-- ...

-- Import verification (run this in a new empty database after running the dump):
SELECT COUNT(*), SUM(price_per_day) FROM tools;
-- Expected: 6 | 750.0 (matches the original).


-- ============================================================
-- PART 5: Assembly (Final Screen of the Database)
-- ============================================================
-- A view joining tools and categories.
CREATE VIEW v_tools_full AS
SELECT t.id, t.name, c.name AS category, t.price_per_day
FROM tools t
JOIN categories c ON t.category_id = c.id;

-- Parameterized query over the view.
SELECT name, price_per_day FROM v_tools_full
WHERE price_per_day >= :min_price
ORDER BY price_per_day DESC;

-- Export and verification from Part 4 are also part of the final screen.