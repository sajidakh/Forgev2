# Hardening (2a)

## Electron
- contextIsolation: true, sandbox: true, webSecurity: true, nodeIntegration: false.
- Permission prompts denied by default; open narrowly only if needed.
- Add a strict CSP when packaging for production.

## API
- Structured JSON logs; never log secrets/PII. Rotation enabled.
- Limit CORS in production to required origins.

## Tooling gates
- scripts\\check-env.ps1 — Node 18.x, Python 3.11.x
- scripts\\check-locks.ps1 — lockfiles present; warn on non-pinned reqs
