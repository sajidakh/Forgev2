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

## Docs
- [Hardening](docs/HARDENING.md)
- [Logging](docs/LOGGING.md)

## Local quality gate (PowerShell)

Run from repo root:

```powershell
.\scripts\run-quality.ps1



## Testing overview

This project has **two complementary test layers**:

### 1) Fast backend/API tests (pytest)
- Location: `backend/python/tests`
- Purpose: Exercise the API directly (no UI); fast feedback & contract checks.
- How we run locally (PowerShell):
  ```powershell
  # from repo root
  .\scripts\run-quality.ps1        # runs pytest as part of the gate

### CI artifacts (Playwright report)

- Our GitHub Actions workflow uploads the **Playwright HTML report** when e2e runs.
- After a CI run, open the workflow run and download the artifact named **playwright-report**.  
  Unzip and open `index.html` in a browser.

**View the report locally** (after a local e2e run):

```powershell
Push-Location ui
npx playwright show-report --port 0 --host 127.0.0.1
Pop-Location
