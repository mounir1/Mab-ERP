# Mab ERP — Test Results

Phase 5 deep-testing record. Updated: 2026-08-18.

## How to run

All tests are opt-in so CI stays green without a live server or database.

### Unit / integration tests

```sh
go test ./...
```

- `internal/database` — `TestRunMigrationsIntegration` runs the full embedded
  migration set against a throwaway database (set `TEST_DATABASE_URL`), checks
  idempotency, and asserts the root `migrations/` directory stays in sync with
  the embedded set (`TestRootMigrationsInSync`, `TestEmbeddedMigrationsSorted`).

### Live smoke tests

Requires a running backend (default `http://localhost:8080`):

```sh
SMOKE_BASE_URL=http://localhost:8080 go test ./smoke/ -v
```

Optional: `SMOKE_USER` / `SMOKE_PASS` (default `admin` / `Admin@123456`).

## Smoke test scope

`smoke/smoke_test.go` covers:

- **Auth guard**: 17 protected routes return 401 without a token.
- **Health**: `/api/health` returns 2xx.
- **Module list endpoints** (2xx each): dashboard, settings, accounting,
  HR, sales, purchase, inventory, manufacturing, projects, treasury, tax,
  workflow, reports, diagnostics, maintenance, fleet, quality, helpdesk,
  assets, budgeting.
- **CRUD round-trips** (create → delete): settings/currency, settings/tax,
  hr/department, inventory/item, sales/customer. Create payloads use a
  per-run unique code so soft-deleted rows from prior runs never collide
  with `(company_id, code)` unique constraints.

## Results

### 2026-08-18 — Migration reconciliation + module smoke pass

**Status: 188/188 checks passing, 0 failures.**

Fixed so handlers match the actual (embedded-migration) schema while keeping
the JSON contract the frontend expects:

| Module | Endpoint | Fix |
| ------ | -------- | --- |
| Settings | fiscal-years | List/Create/Close now use `is_closed` (no `status`/`is_current` columns); `status`/`is_current` derived in SQL |
| Accounting | fixed-assets | Query aliases real columns: `asset_number→code`, `purchase_cost→purchase_value`, `salvage_value→residual_value`, `net_book_value→current_value`; category joined via `asset_categories`; create/depreciation updated to real columns (`net_book_value` is GENERATED) |
| Treasury | cash-accounts | `account_type` derived from `account_id`, `account_number` from `code`, `opening_balance`/`notes`/`updated_at` synthesized; create/update map to real columns |
| Fleet | vehicles, maintenance | `mileage_at_fill` → `odometer_km` (vehicles + maintenance tables); `fleet_fuel_logs` already had the column |
| Quality | non-conformities, corrective-actions | `closed_at` → `closed_date`; removed `closed_by` writes; `verified_date` (not `verification_date`); `ca_tasks` uses `status`/`completed_date`/`title` (no `sequence`/`completed`) |
| Assets | assets | `in_service_date→depreciation_start`, `manufacturer→brand`, `warranty_expiry_date→warranty_expiry`, `is_depreciable` derived from `useful_life_years`, date columns `::text`-cast in `COALESCE` to avoid `invalid input syntax for type date: ""` |
| Assets | locations | dropped non-existent `code` column |
| Assets | transfers | `approved_at` cast to `::text` before `COALESCE` (timestamptz) |
| Assets | maintenance | `completed_date→completed_at`, `technician→performed_by`, `parts_used→parts_replaced`, `notes→actions_taken` |
| Smoke harness | CRUD | unique per-run code suffix so repeats don't hit unique-constraint collisions |

### Demo seed applied

`scripts/seed_demo.sql` was applied to the live `mab_erp` database and verified:

```sh
.dev/pg/pgsql/bin/psql.exe -h 127.0.0.1 -U postgres -d mab_erp -v ON_ERROR_STOP=1 -f scripts/seed_demo.sql
```

- Runs in a single transaction (`BEGIN`/`COMMIT`) — any error rolls back the
  whole seed, so the script is safe to re-run (`ON CONFLICT (id) DO NOTHING`
  makes it idempotent; second run reports `INSERT 0 0`).
- Seeds all modules: org (6 depts, 4 employees), CRM (4 customers), sales
  (2 quotations, 2 orders, 1 invoice), purchase (3 suppliers, 2 POs, 1 GRN),
  inventory (5 items), manufacturing, projects, treasury (payments/cheques),
  tax (declarations + VAT register), fleet (2 vehicles, fuel logs), quality
  (inspections, NCRs, corrective actions), helpdesk (2 tickets), fixed assets,
  budgeting (annual budget + line items), maintenance (plans + orders), HR
  (payroll run + payslips).
- Smoke suite re-run against the seeded DB: **188/188 passing**.
- Seed values respect the real schema: generated columns (e.g. `subtotal`,
  `balance_due`, `qty_available`, `net_book_value`) are omitted from inserts;
  JSON columns (`equipment.specifications`, `preventive_maintenance_plans.tasks/checklist`,
  `maintenance_orders.team_members`, `payslips.irg_bracket`) hold valid JSON;
  check/enum constraints (quality `check_type`, `overall_result`, `applies_to`,
  `root_cause_method`, budget `status`) use allowed literals; UUID refs to
  `users` point at the seeded admin; `vat_rate` is stored as `0.19` per
  `numeric(5,4)`.

### Previously fixed (this cycle)

- Migration reconciliation: added `0022_fix_company_currencies` (creates
  `company_currencies`, seeds DZD + taxes), synced root `migrations/` with the
  embedded set (22 files each).
- Verified clean install: `TestRunMigrationsIntegration` on a throwaway DB
  applies all 22 migrations idempotently (144 public tables, `company_currencies`
  present).
- Verified live: `/api/settings/currencies` returns DZD; `/api/settings/taxes`
  returns TVA19, TVA9, TVA0, TAP2; DB encoding is correct UTF-8.

## Remaining

- Per-module UI walkthrough (frontend field names vs. API JSON) — some modules
  may still reference old key names in Vue components.
- Edge-case tests (permissions per role, pagination, soft-delete semantics).
- Re-apply the demo seed on any fresh database reset (command above).