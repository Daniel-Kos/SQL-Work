# PR15 Report: Variables, Program File, and Tabular Files

## Part 1: Variables (or CTE)
SQLite does not support session variables, so the portable CTE (`WITH`) approach is used.
*   Maximum deposit: 5000 (the number depends on your database).
*   Total rentals: 5.

## Part 2: Program File
The script is fully rerunnable. Running it twice does not cause errors.
Control numbers after the first run:
*   Rows in `demo_tools`: 6
*   MIN and MAX price: 60 and 390
*   AVG price: 220.0

## Part 3: Array (Temp Table)
*   Items in the `batch` array: 3.
*   Maximum price: 420.
*   `UPDATE` changed 1 row (Ladder 3m, new price is 130).

## Part 4: CSV Import
*   Rows in `tools_stage` after import: 3.
*   Rows inserted into `demo_tools` using `NOT EXISTS`: 2 (the third was filtered out as it already existed).
*   Total rows in `demo_tools` after transfer: 8.
*   New maximum price: 420.

## Part 5: CSV Export
Exported 8 data rows + 1 header row. Total: 9 lines in the file.