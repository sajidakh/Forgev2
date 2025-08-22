# Forge (Desktop-first) — MVP Scaffold

Windows .exe (Electron + React) with a Python FastAPI backend. Later: lift-and-shift to SaaS.

## Quickstart
```powershell
# one-time (Python 3.11, Node 18+)
cd C:\GitRepos\Forge_v2
python -m venv backend\python\.venv
backend\python\.venv\Scripts\pip install -r backend\python\requirements.txt
cd ui && npm install && cd ..
cd electron && npm install && cd ..

# dev
.\scripts\start-dev.ps1
.\scripts\smoke.ps1
```

## Scripts
- `scripts\start-dev.ps1` — boots API, UI, Electron (cd-safe)
- `scripts\smoke.ps1` — quick API health ping
- `scripts\run-tests.ps1` — **green gate**: UI build + ephemeral API health
- `scripts\install-git-hooks.ps1` — installs pre-commit (runs tests on every commit)

## Branch Model
- **Scaffolding**: commit to `main` only if tests are green.
- **Business logic**: create `dev` from `main`; commit to `dev` (green required); merge `dev → main`; smoke; tag.

## Layout
- `backend/python` — FastAPI (`app.py`)
- `ui` — Vite + React + TS; `HealthCheck` pings `/health`
- `electron` — shell wrapping the Vite UI
- `scripts` — PowerShell orchestrators (cd-safe)
- `docs` — Prime Directives, risk register, etc.

## License
Replace placeholder with your choice (MIT/Apache-2.0) before first release.
