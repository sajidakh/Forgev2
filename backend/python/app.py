"""Forge API (Step 2)

Adds:
- /version endpoint (simple version string)
- Structured JSON logs with x-request-id propagation
- Log rotation to backend/python/logs/forge_api.log
"""

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from uuid import uuid4
from logging.handlers import RotatingFileHandler
import logging
import json
import time
import os

APP_VERSION = "0.1.0-step2"


def setup_logging() -> logging.Logger:
    """Create a JSON logger with rotation under backend/python/logs."""
    base_dir = os.path.dirname(__file__)
    log_dir = os.path.join(base_dir, "logs")
    os.makedirs(log_dir, exist_ok=True)
    logger = logging.getLogger("forge")
    logger.setLevel(logging.INFO)
    if not logger.handlers:
        file_path = os.path.join(log_dir, "forge_api.log")
        fh = RotatingFileHandler(file_path, maxBytes=1_000_000, backupCount=5, encoding="utf-8")
        ch = logging.StreamHandler()
        fmt = logging.Formatter("%(message)s")  # message will be JSON string
        fh.setFormatter(fmt)
        ch.setFormatter(fmt)
        logger.addHandler(fh)
        logger.addHandler(ch)
    return logger


logger = setup_logging()
app = FastAPI(title="Forge API", version=APP_VERSION)

# CORS for local dev UI
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://127.0.0.1:5173", "http://localhost:5173"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.middleware("http")
async def add_request_id(request: Request, call_next):
    """Propagate/generate x-request-id, log every request as structured JSON."""
    request_id = request.headers.get("x-request-id", str(uuid4()))
    start = time.time()
    response = await call_next(request)
    duration_ms = int((time.time() - start) * 1000)
    response.headers["x-request-id"] = request_id
    response.headers["x-duration-ms"] = str(duration_ms)
    try:
        payload = {
            "ts": int(time.time() * 1000),
            "level": "info",
            "event": "http_request",
            "request_id": request_id,
            "method": request.method,
            "path": request.url.path,
            "status": response.status_code,
            "duration_ms": duration_ms,
            "ua": request.headers.get("user-agent", ""),
            "client": request.client.host if request.client else None,
        }
        logger.info(json.dumps(payload, ensure_ascii=False))
    except Exception:
        # never block the request if logging fails
        pass
    return response


@app.get("/health")
def health():
    return {"status": "ok", "service": "forge-api"}


@app.get("/version")
def version():
    return {"version": APP_VERSION}
