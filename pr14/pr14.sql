-- ============================================================
-- PR14. Sorting, Filtering, and Searching Data (SQLite)
-- ============================================================

-- ============================================================
-- PART 1: Sorting (ORDER BY, LIMIT/OFFSET)
-- ============================================================
-- Top-3 most expensive tools
SELECT name, price_per_day FROM tools
ORDER BY price_per_day DESC
LIMIT 3;

-- Sort by category (alphabetically), then by price (descending)
SELECT category, name, price_per_day FROM tools
ORDER BY category, price_per_day DESC;

-- Page 3: skip 4, show 2
SELECT name, price_per_day FROM tools
ORDER BY price_per_day DESC
LIMIT 2 OFFSET 4;

-- NULLs first when sorting by return_date ascending
SELECT id, tool_id, rent_date, return_date FROM rentals
ORDER BY return_date;

-- ============================================================
-- PART 2: Filtering (BETWEEN, IN, IS NULL)
-- ============================================================
-- Range: tools with medium price
SELECT name, price_per_day FROM tools
WHERE price_per_day BETWEEN 60 AND 500
ORDER BY price_per_day;

-- List: rentals of three specific clients
SELECT * FROM rentals
WHERE client_id IN (1, 2, 3);

-- Empty: tools not returned yet
SELECT * FROM rentals
WHERE return_date IS NULL;

-- Trap: NULL is not found with "="
SELECT COUNT(*) FROM rentals WHERE return_date = NULL; -- 0 rows

-- Correct combination with parentheses
SELECT * FROM rentals
WHERE (client_id = 1 OR client_id = 2) AND return_date IS NULL;

-- Wrong combination (without parentheses)
SELECT * FROM rentals
WHERE client_id = 1 OR client_id = 2 AND return_date IS NULL;

-- ============================================================
-- PART 3: Text Search (LIKE)
-- ============================================================
-- Starts with "Дрел"
SELECT name FROM tools WHERE name LIKE 'Дрел%';

-- Contains "олоток" anywhere
SELECT name FROM tools WHERE name LIKE '%олоток%';

-- Case sensitivity check for Cyrillic
SELECT name FROM tools WHERE name LIKE '%Молоток%';
SELECT name FROM tools WHERE name LIKE '%молоток%';

-- Reliable search if case-sensitive (both cases)
SELECT name FROM tools WHERE name LIKE '%Молоток%' OR name LIKE '%молоток%';

-- The "ё" trap: search "Петр" vs "Пётр"
-- Use underscore (_) to match both: 'Пет_р'
SELECT name FROM clients WHERE name LIKE 'Пет_р';

-- ============================================================
-- PART 4: Multi-field Search (AND/OR, two-step)
-- ============================================================
-- Everything related to tool 5 or client 3
SELECT * FROM rentals
WHERE tool_id = 5 OR client_id = 3;

-- Expensive and old: deposit >= 1000, rented before November
SELECT * FROM rentals
WHERE deposit >= 1000 AND rent_date < '2026-11-01';

-- Two-step search: find client ID by name, then search rentals
SELECT id, name FROM clients WHERE name LIKE '%Петр%';
SELECT * FROM rentals WHERE client_id = 2;

-- Distinct clients who had rentals
SELECT DISTINCT client_id FROM rentals ORDER BY client_id;

-- ============================================================
-- PART 5: Inventory – Ten Queries
-- ============================================================

-- 1. Sort by two columns
SELECT category, name, price_per_day FROM tools
ORDER BY category, price_per_day DESC;

-- 2. Sort with LIMIT/OFFSET
SELECT name, price_per_day FROM tools
ORDER BY price_per_day DESC
LIMIT 2 OFFSET 4;

-- 3. Sort with NULL in the sorted column
SELECT id, return_date FROM rentals
ORDER BY return_date;

-- 4. Filter with BETWEEN
SELECT name, price_per_day FROM tools
WHERE price_per_day BETWEEN 60 AND 500;

-- 5. Filter with IN
SELECT * FROM rentals WHERE client_id IN (1, 2, 3);

-- 6. Filter with IS NULL
SELECT * FROM rentals WHERE return_date IS NULL;

-- 7. Text search with case check
SELECT name FROM tools WHERE name LIKE '%Молоток%';

-- 8. Text search with underscore (_)
SELECT name FROM clients WHERE name LIKE 'Пет_р';

-- 9. Composite search with AND/OR and parentheses
SELECT * FROM rentals
WHERE (client_id = 1 OR client_id = 4) AND deposit >= 500 AND return_date IS NULL;

-- 10. Two-step search: find client ID by name, then search rentals
SELECT id, name FROM clients WHERE name LIKE '%Петр%';
SELECT * FROM rentals WHERE client_id = 2;