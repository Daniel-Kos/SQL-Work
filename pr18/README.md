# PR18 Report: Working and System Windows

## Working Windows in My Client (SQLite / DB Browser for SQLite)
1. **Database Structure** (Object Explorer): Shows the tree of tables and views.
2. **Execute SQL** (Query Editor): The tab where I write and run my `pr18.sql` script.
3. **Browse Data** (Results Grid): The tab that shows the output of the last executed `SELECT`.

## Connection Window in My Client
The connection is made by opening a database file (e.g., `pr18.db`). The window is called **"Open Database"** or **"Connect"** in the File menu. It asks for the path to the `.db` file.

## How Parameters Work in SQLite
SQLite does not support session variables like `@var` or `DECLARE`. The client supplies values using placeholders:
- In Python: `?` or `:name`.
- In the `sqlite3` CLI: `.parameter set :name value`.
In my script I use the `:min_price` placeholder.

## Import Verification Numbers
- Original `tools` table: 6 rows | 750.0 total.
- Copy after import: 6 rows | 750.0 total.
(The numbers match, so the import was successful.)