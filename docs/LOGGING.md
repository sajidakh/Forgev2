# Logging (API)

- **Structured JSON** lines are written to console and to `backend/python/logs/forge_api.log`.
- Every request gets a `request_id` (from `x-request-id` if provided, else generated).
- Fields: `ts`, `level`, `event`, `request_id`, `method`, `path`, `status`, `duration_ms`, `ua`, `client`.
- Rotation: 1MB per file, 5 backups.

Logging failures never block requests.
