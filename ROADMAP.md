# Mab ERP — Project Roadmap

Rebrand of **Nexus ERP → Mab ERP** (full internal rename), hardening, testing, assets,
credits, and production deployment behind an **Apache** web server.

Status: 📋 Planned
Current baseline: backend + DB + Vite dev server running locally (migrations fixed, all 20 applied).

---

## Phase 0 — Baseline & Test Harness (clean foundation)

**Goal:** A reproducible starting point before touching branding, so every later change is verifiable.

- [ ] Snapshot current working state: commit migration fixes (`0001`, `0009`, `0011`, `0012`, `db.go ON CONFLICT`)
- [ ] Fix `.gitignore`: add `.dev/`, `cmd/`, `web/dist/`, `web/node_modules/`
- [ ] Remove junk/risky committed files:
      `backup_nexuserp_*.sql` (DB dump with data), `web/src/src`, `web/web`
- [ ] Reconcile duplicate migration sets → single source of truth
      (root `migrations/` currently diverges from `internal/database/migrations/`; embedded copy governs)
- [ ] Add test scripts + CI-style gates: `go vet`, Go unit tests, frontend `type-check` + `lint`
- [ ] **Exit check:** clean `git status`, app boots from scratch, `npm run build` + binary rebuild succeed

## Phase 1 — Rebrand to "Mab ERP" (full rename)

Name token mapping (used everywhere, all the following files):

| Old | New |
|---|---|
| `Nexus ERP` / `Nexus` | `Mab ERP` / `Mab` |
| `nexus-erp` (paths, images, containers) | `mab-erp` |
| `nexus_erp` (DB name) | `mab_erp` |
| `nexus` (user/tenant/keys) | `mab` |

### 1A. Backend / Go
- [ ] `go.mod` module path + all `nexus-erp/internal/...` import paths → `mab-erp/internal/...`
- [ ] `main.go` startup log line, `//go:embed` unchanged
- [ ] `db.go` default `DB_NAME` `nexus_erp` → `mab_erp`
- [ ] `cmd/dbsetup/main.go` DB/user names
- [ ] SQL seeds in `0001_init_schema.sql`: tenant code `'NEXUS'`→`'MAB'`, names, `admin@nexus-erp.local` → `admin@mab-erp.local`; update all `-- Nexus ERP - ...` migration header comments

### 1B. Frontend / Vue
- [ ] `web/index.html` + root `index.html`: `<title>`, meta description, favicon (new logo)
- [ ] `Sidebar.vue`, `Login.vue`, `AppBar.vue`, `StatusBar.vue` brand text, tagline, footer
- [ ] `App.vue` root id, `router/index.ts` document.title template
- [ ] `stores/auth.ts` localStorage keys `nexus_*` → `mab_*`; `stores/app.ts` `nexus-theme` → `mab-theme`
- [ ] `package.json` (`web/` + root) name/description

### 1C. Build / Deploy / Docs
- [ ] `docker-compose.yml`: service/container/volume/network names, `nexus_erp` DB, `nexus` user, pgadmin email
- [ ] `Dockerfile`: labels, output binary `/nexus-erp` → `/mab-erp`
- [ ] `env.example` + `.env`: `nexus_erp`, `S3_BUCKET=nexus-erp-files`, `SMTP_FROM`, `VITE_APP_NAME`
- [ ] `scripts/build.sh` output/zip names
- [ ] `README.md` full pass; `asset/Nexus-ERP.gif` → `asset/Mab-ERP.gif`

### 1D. New branding assets (Phase 3 deliverables, wired here)
- [ ] Proper logo (SVG + favicon + inline mark) — replace letter blocks
- [ ] Unify version strings (`v1.0.0` vs `v1.1.0` inconsistency)

**Exit check:** `rg -in "nexus" --glob '!web/dist' --glob '!node_modules'` returns only LICENSE/attribution hits; full rebuild works.

## Phase 2 — Hardening & Bug Fixes (after first testing sessions)

Findings already logged from the audit:

- [ ] **CORS**: replace `AllowOrigins: ["*"]` + `AllowCredentials: true` with `CORS_ORIGINS` env-driven allowlist
- [ ] **JWT secret**: fail fast if `JWT_SECRET` unset (remove hardcoded fallback in 2 places)
- [ ] **`/api/health`** route (compose healthcheck references it; currently 404)
- [ ] Env mismatch: code reads `PORT`, compose sets `APP_PORT` — unify; wire `JWT_EXPIRY_HOURS`, `REFRESH_TOKEN_EXPIRY_DAYS`, `CORS_ORIGINS`, `LOG_LEVEL`
- [ ] **Logout** is a no-op → add refresh-token revocation/rotation
- [ ] Implement `ForgotPassword` / `ResetPassword` stubs (currently TODO)
- [ ] Implement `AuditLog` middleware (TODO), `hasPermission` in auth store (stub)
- [ ] `purchase_inventory.go:270` goods-receipt TODO (PO received quantities + stock movements)
- [ ] Rate limiting on `/api/auth/*`
- [ ] `npm audit` fixes (2 vulns) + replace deprecated `lucide-vue-next`
- [ ] Tests: Go unit tests (handlers/db/migration runner), frontend type-check/lint as gates

**Exit check:** `go vet ./...`, tests green, fresh migration run, auth reboot safe.

## Phase 3 — Assets, Credits & Polish

- [ ] Design logo (SVG) + favicon + optional demo GIF `asset/Mab-ERP.gif`
- [ ] Login page brand polish (hero, tagline, footer alignment)
- [ ] **Credits section** in README + settings/about screen (author: Brahim TIM, contributors, the original Nexus ERP lineage, licensing/attribution)
- [ ] LICENSE file vs README "All rights reserved" conflict — reconcile (MIT)

## Phase 4 — Production Deployment (Apache server)

### Requirements & install specs (to be finalized once your server is known)
- **Server:** Linux VPS, ≥2 vCPU, ≥4 GB RAM, ≥20 GB SSD; Ubuntu 22.04/24.04 or Debian 12
- **Stack:** PostgreSQL 16, Go binary or container, Apache 2.4 (mod_proxy, mod_proxy_http, mod_ssl, mod_rewrite), certbot/SSL
- **Architecture (recommended):** systemd runs the embedded-frontend binary on `127.0.0.1:8080`; Apache terminates TLS and reverse-proxies `VirtualHost:443 → localhost:8080` (no PHP needed — frontend is compiled into the binary)
- Alternative: Docker Compose on the server (postgres + binary container), Apache still terminates TLS + proxy
- Steps:
  - [ ] Server provisioning checklist (OS, updates, firewall, fail2ban, backups)
  - [ ] PostgreSQL 16 install + `mab_erp` DB/user (strong passwords), `pg_hba` hardening
  - [ ] Build release binary/container (CGO_ENABLED=0, ldflags version stamp)
  - [ ] systemd unit or compose file; `.env` with real secrets (12-byte+ JWT, CORS origin)
  - [ ] Apache vhost + SSL (certbot), static asset caching, gzip/brotli
  - [ ] Backup job (`pg_dump` + retention) and restore drill
  - [ ] Healthcheck + uptime/log rotation

### Tuning checklist (server + app)
- [ ] PostgreSQL: `shared_buffers`, `work_mem`, `max_connections`, `effective_cache_size` per RAM plan
- [ ] App: `GOMEMLIMIT`/`GOMAXPROCS`, pool MaxConns/MinConns, index review on hot tables
- [ ] Apache: MPM worker tuning, keepalive, timeouts
- [ ] Load test (e.g. `ab`/`hey`) baseline before and after tuning

## Phase 5 — Deep Testing Sessions (module-by-module)

Iterate for all **24 modules** (auth, dashboard, accounting, hr, sales, purchase, inventory,
manufacturing, projects, treasury, tax, workflow, reports/BI, diagnostics, maintenance, fleet,
quality, helpdesk, assets, budgeting, settings): test → fix → commit.

- [ ] Build a smoke-test checklist per module (CRUD, auth guard, permissions, edge cases)
- [ ] Regression pass after each fix batch
- [ ] Record results in `TESTING.md` (what passed, what was fixed)

**Exit check:** complete module test matrix, all Phase-2 fixes verified under test.

## Phase 6 — Finalize & Publish

- [ ] Version bump + changelog (v1.0.0 → v1.1.0)
- [ ] Final credits/attribution pass
- [ ] Tag release; push to GitHub (rename repo to `Mab-ERP` and update remote)
- [ ] Deploy to Apache server per Phase 4
- [ ] Post-deploy verification (login, health, TLS, backup on) + go-live announcement

---

## Guiding principles
- Commit at each milestone boundary (never break a working baseline).
- One source of truth for migrations; `web/dist` and `node_modules` never committed.
- Secrets never committed again (DB dump removal is Phase 0).
- Every "fix" must be reproducible via the test harness before it ships.