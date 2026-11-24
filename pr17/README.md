# PR17 Report: Menus, Views, and Modification

## List of Menu Items (Views)
1. **`v_price`** (Projection): Shows only the tool name and price.
2. **`v_open`** (Filter): Shows only rentals that have not been returned yet (return_date is NULL).
3. **`v_rentals_full`** (Join): Combines rentals with client and tool names for readability.
4. **`v_client_deposits`** (Aggregate): Groups clients and calculates the total count and sum of their deposits.
5. **`v_open_full`** (View over View): Takes `v_rentals_full` and filters for open rentals.

## Modifying a View in SQLite
SQLite does not support `ALTER VIEW` or `CREATE OR REPLACE VIEW`. To modify a view, you must drop it and create it again.
*   **Error message for `ALTER VIEW`:** `OperationalError: near "VIEW": syntax error`
*   **Error message for `CREATE OR REPLACE VIEW`:** `OperationalError: near "OR": syntax error`

## Client GUI Actions (Simulated for DB Browser for SQLite)
*   **Create/View:** Right-click the "Views" node in the "Database Structure" tab -> "Create View" / "Browse Data".
*   **Modify:** Right-click the view -> "Modify View".
*   **Delete:** Right-click the view -> "Delete View".