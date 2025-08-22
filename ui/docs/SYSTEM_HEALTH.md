# System Health Panel

Four quick checks for local dev:

- **Ping API** → GET /health (adds `x-request-id`) and renders status.
- **API Version** → GET /version to show the API version string.
- **Electron IPC echo** → round-trip message via `window.forge.echo`.
- **UI Env/Config** → displays `VITE_API_URL` and whether Electron preload is present.

All actions are small and deterministic. Extend as needed.
