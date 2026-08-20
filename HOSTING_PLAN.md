# Mab ERP — Free Demo Hosting Plan

Prepared 2026-08-20. Goal: publish the demo online for **$0** with a free domain, supporting the project's real stack.

## 1. What actually needs hosting (verified from the repo)

| Piece | What the project uses | Where |
|---|---|---|
| Backend | Go 1.21 + Gin (single binary) | `main.go`, `go.mod` |
| Frontend | Vue 3 + TypeScript + Vite + Tailwind | `web/` |
| Serving model | Go binary **embeds** the built SPA (`//go:embed web/dist`) — one process serves UI + API | `main.go:22` |
| Database | PostgreSQL via `pgx` (reads `DATABASE_URL`, runs embedded SQL migrations on boot) | `internal/database/db.go` |
| Config | env vars: `DATABASE_URL`, `JWT_SECRET` (≥32 chars), `APP_ENV`, `PORT`, `CORS_ORIGINS`, `LOG_LEVEL` | `main.go`, `env.example` |
| Containerization | `Dockerfile` + `docker-compose.yml` already present | repo root |

**Key consequence:** because the frontend is embedded, this is a **single deployable** — you only need (a) somewhere to run a Go binary and (b) a managed PostgreSQL. Firebase Hosting cannot run a Go server, so Firebase is **not a fit** for the backend; Supabase is useful but only as the database.

## 2. Recommended free architecture (all $0)

```
User ── HTTPS ──> Free domain (is-a.dev / DuckDNS)
                        │
                        ▼
              Render Free Web Service (Go binary, serves UI + API)
                        │
                        ▼
            Supabase PostgreSQL (free 500 MB)   ← DATABASE_URL
```

## 3. Best free deals compared

| Provider | Role | Free tier | Fits? | Caveats |
|---|---|---|---|---|
| **Render** | App host | 1 web service, 750 hrs/mo, 512 MB RAM, auto-TLS, auto-deploy from GitHub | ✅ **Best fit** | Spins down after 15 min idle (~30–60 s cold start) |
| Fly.io | App host | ~3 shared-cpu-1x apps / month, 3 GB volume | ✅ good | Needs credit card on signup |
| Koyeb | App host | 1 free service, always-on nano | ✅ good | Single region |
| Railway | App host | $5 trial credit | ⚠️ | Credit card required; trial-limited |
| **Supabase** | Postgres | 500 MB DB, auth, storage | ✅ **Best DB fit** (you asked) | Free project pauses after 1 week inactivity |
| Neon | Postgres | 0.5 GB, autosuspend, branches | ✅ excellent alt | Serverless (some latency on wake) |
| Render Postgres | Postgres | Free tier | ❌ avoid | Free DB **expires after 30 days** |

**Recommendation: Render (app) + Supabase (DB).** Fallback: Fly.io (app) + Neon (DB).

## 4. Step-by-step publish

1. **Build the frontend** so the binary embeds it:
   ```powershell
   cd web; npm ci; npm run build   # produces web/dist (embedded via go:embed)
   cd ..
   go build -o app .               # verify it compiles with the embedded dist
   ```
   (The repo already builds this way via `scripts/build.sh`.)

2. **Push the repo to GitHub** (a `.git` repo already exists).

3. **Create Supabase project** → copy the `postgres://...?sslmode=require` connection string.
   Migrations run automatically on boot (embedded SQL), so no manual schema work is needed.

4. **Create the Render web service:**
   - New → Web Service → connect the GitHub repo.
   - Build command: `cd web && npm ci && npm run build && cd .. && go build -o app .`
   - Start command: `./app`
   - Environment variables:
     - `DATABASE_URL` = Supabase connection string (with `sslmode=require`)
     - `JWT_SECRET` = a random string ≥ 32 chars
     - `APP_ENV` = `production`
     - `CORS_ORIGINS` = `https://yourdomain` (and the `.onrender.com` URL)

5. **Deploy** → open `https://mab-erp.onrender.com` → login with the seeded admin.

6. **Point a free domain at it** (optional, step 7).

## 5. Free domain options

| Option | Cost | Effort | Notes |
|---|---|---|---|
| `*.onrender.com` | Free | Zero | Built into Render; add a custom domain later |
| **is-a.dev** | Free | ~10 min | Real domain via GitHub; add a CNAME record to Render |
| DuckDNS (`*.duckdns.org`) | Free | ~5 min | Simple CNAME |
| `*.eu.org` | Free | Days (manual review) | Permanent, reputable |
| Freenom (`.tk/.ml/...`) | ❌ | — | Service discontinued — avoid |

Recommended: **is-a.dev** or just use the `onrender.com` subdomain for the demo.

## 6. Expected result & cost

- **Monthly cost: $0** (Render free service + Supabase free project + free domain).
- Demo URL: `https://mab-erp.onrender.com` (or custom `https://yourname.is-a.dev`).
- HTTPS: automatic.

## 7. Caveats to know before the demo

- Render free apps sleep after 15 min idle → first request can take ~30–60 s. Fix later with a paid tier or a keep-alive ping.
- Supabase free projects pause after 1 week without activity (one click to resume).
- For a **permanent always-on** demo later: Oracle Cloud Always Free (2 AMD + 4 Arm VMs, free forever) or a ~$4/mo VPS running `./app` behind Caddy/nginx.
- Keep `JWT_SECRET` and the DB password out of git (use Render/Supabase env stores).