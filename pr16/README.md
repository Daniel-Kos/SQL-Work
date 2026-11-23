# PR16 Report: Arrays, CSV I/O, and Load Verification

## Part 1: Multi-row VALUES
*   `COUNT(*)` in `clients` before insert: 5.
*   `COUNT(*)` after insert: 8.
*   Error when inserting a broken tuple: `3 values for 2 columns`. The table remains at 8 rows (insert is atomic).
*   `COUNT(*)` and `SUM(deposit)` in `rentals` before my batch: 8 | 5450.0.
*   `COUNT(*)` and `SUM(deposit)` after my batch (added 4 rows): 12 | 7950.0.

## Part 2: INSERT ... SELECT
*   Before transfer (`rentals`): 12 rows | 7950.0 deposit.
*   Moved to `rentals_archive`: 4 rows | 2900.0 deposit.
*   After deletion (`rentals`): 8 rows | 5050.0 deposit.
*   Verification equality: 5050.0 + 2900.0 = 7950.0 (Data is intact).
*   `COUNT(*)` in `tools` after `UNION ALL` insert: 12.

## Part 3: Temporary Table (Staging)
*   `COUNT(*)`, `COUNT(DISTINCT name)` in `stage_tools`: 6 and 5.
*   Duplicate found: 'Ключ разводной' (2 rows).
*   Error on direct transfer: `UNIQUE constraint failed: tools.name`.
*   `COUNT(*)` in `tools` after cleaning the duplicate and inserting: 16.
*   Explanation for 'Перфоратор' not being inserted: It already existed in the `tools` table, so the `NOT EXISTS` condition filtered it out.

## Part 4: CSV I/O
*   Exported `tools.csv` has 15 lines (1 header + 14 data rows). Texts are enclosed in double quotes, values separated by commas.
*   Imported into `tools_import`: 14 rows | 3640.0 sum. Source `tools` also has 14 rows | 3640.0 sum.
*   Import without skipping header: SQLite throws `INSERT failed: datatype mismatch`. The table stays at 14 rows.

## Part 5: Aggregate Functions
*   `rentals` card: `COUNT(*)=8`, `SUM=5050.0`, `AVG=631.25`, `MIN=150.0`, `MAX=1000.0`.
*   CSV cross-check: source and staging both have 14 rows and 3640.0 sum.
*   `COUNT(*)` vs `COUNT(phone)` in `clients`: 8 vs 5 (3 clients have NULL phone).
*   `GROUP BY category` in `tools`: Измерение (3 positions), Ручной инструмент (6 positions), Электроинструмент (7 positions).