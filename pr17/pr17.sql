-- ================ МЕНЮ БАЗЫ ПРОКАТА ================
-- PR17: Views as menu items; execute top to bottom.
-- 1. CREATE  - five CREATE VIEW
-- 2. SHOW    - SELECT from each view
-- 3. MODIFY  - drop and recreate a view with a new column
-- 4. DELETE  - DROP VIEW IF EXISTS
-- ====================================================

-- Setup tables (simulating the rental database)
DROP TABLE IF EXISTS rentals;
DROP TABLE IF EXISTS tools;
DROP TABLE IF EXISTS clients;

CREATE TABLE clients (id INTEGER PRIMARY KEY, name TEXT NOT NULL);
CREATE TABLE tools (id INTEGER PRIMARY KEY, name TEXT NOT NULL, category TEXT, price_per_day REAL);
CREATE TABLE rentals (id INTEGER PRIMARY KEY, client_id INTEGER, tool_id INTEGER, rent_date TEXT, return_date TEXT, deposit REAL);

INSERT INTO clients VALUES (1, 'Иванов'), (2, 'Смирнова'), (3, 'Кузнецов');
INSERT INTO tools VALUES (1, 'Дрель', 'Электро', 150), (2, 'Молоток', 'Ручной', 60), (3, 'Перфоратор', 'Электро', 250);
INSERT INTO rentals VALUES (1, 1, 1, '2026-11-01', '2026-11-02', 1000), (2, 2, 2, '2026-11-03', NULL, 300), (3, 3, 3, '2026-11-04', NULL, 500);


-- ====================================================
-- 1. CREATE: Menu items (Views)
-- ====================================================
-- Projection
CREATE VIEW v_price AS
SELECT name, price_per_day FROM tools;

-- Filter
CREATE VIEW v_open AS
SELECT id, client_id, tool_id, rent_date, deposit
FROM rentals
WHERE return_date IS NULL;

-- Join
CREATE VIEW v_rentals_full AS
SELECT r.id, c.name AS client, t.name AS tool, r.rent_date, r.return_date, r.deposit
FROM rentals r
JOIN clients c ON r.client_id = c.id
JOIN tools t ON r.tool_id = t.id;

-- Aggregate
CREATE VIEW v_client_deposits AS
SELECT c.name, COUNT(r.id) AS rentals_cnt, SUM(r.deposit) AS deposits_total
FROM clients c
LEFT JOIN rentals r ON r.client_id = c.id
GROUP BY c.id, c.name;

-- View over View
CREATE VIEW v_open_full AS
SELECT * FROM v_rentals_full
WHERE return_date IS NULL;


-- ====================================================
-- 2. SHOW: Queries over views
-- ====================================================
SELECT name, price_per_day FROM v_price ORDER BY price_per_day DESC;

SELECT client, tool FROM v_open_full;

-- Refining queries
SELECT name, price_per_day FROM v_price WHERE price_per_day >= 120;

-- Verify live data: insert new open rental
INSERT INTO rentals VALUES (4, 1, 3, '2026-11-10', NULL, 300);
SELECT id, tool_id, deposit FROM v_open;
-- The new row appears automatically.


-- ====================================================
-- 3. MODIFY: Changing a view
-- ====================================================
-- Attempting ALTER VIEW (will fail in SQLite)
ALTER VIEW v_price AS SELECT name, price_per_day, category FROM tools;
-- ERROR: OperationalError: near "VIEW": syntax error

-- Correct way in SQLite: DROP and CREATE
DROP VIEW v_price;
CREATE VIEW v_price AS
SELECT name, price_per_day, category FROM tools;

SELECT * FROM v_price LIMIT 1; -- Verify new column


-- ====================================================
-- 4. DELETE: Removing a view
-- ====================================================
DROP VIEW IF EXISTS v_open_full;

-- Attempting to drop again to show error (commented out)
-- DROP VIEW v_open_full;
-- ERROR: no such view: v_open_full