from fastapi import FastAPI, Request, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from uuid import uuid4
from logging.handlers import RotatingFileHandler
import logging
import json
import time
import os
from config import Settings

settings = Settings()
APP_VERSION = settings.api_version


def setup_logging() -> logging.Logger:
    base_dir = os.path.dirname(__file__)
    log_dir = os.path.join(base_dir, settings.log_dir)
    os.makedirs(log_dir, exist_ok=True)
    lg = logging.getLogger("forge")
    lg.setLevel(logging.INFO)
    if not lg.handlers:
        fp = os.path.join(log_dir, "forge_api.log")
        fh = RotatingFileHandler(fp, maxBytes=1_000_000, backupCount=5, encoding="utf-8")
        ch = logging.StreamHandler()
        fmt = logging.Formatter("%(message)s")
        fh.setFormatter(fmt)
        ch.setFormatter(fmt)
        lg.addHandler(fh)
        lg.addHandler(ch)
    return lg


logger = setup_logging()
app = FastAPI(title=settings.api_name, version=APP_VERSION)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.middleware("http")
async def add_request_id(request: Request, call_next):
    rid = request.headers.get("x-request-id", str(uuid4()))
    start = time.time()
    try:
        resp = await call_next(request)
    finally:
        dur = int((time.time() - start) * 1000)
        try:
            payload = {
                "ts": int(time.time() * 1000),
                "level": "info",
                "event": "http_request",
                "request_id": rid,
                "method": request.method,
                "path": request.url.path,
                "status": getattr(locals().get("resp", None), "status_code", 0),
                "duration_ms": dur,
                "ua": request.headers.get("user-agent", ""),
                "client": request.client.host if request.client else None,
            }
            logger.info(json.dumps(payload, ensure_ascii=False))
        except Exception as e:
            warn = {
                "ts": int(time.time() * 1000),
                "level": "warning",
                "event": "logging_error",
                "request_id": rid,
                "error": str(e),
            }
            try:
                logger.warning(json.dumps(warn, ensure_ascii=False))
            except Exception:
                ...
    resp.headers["x-request-id"] = rid
    resp.headers["x-duration-ms"] = str(dur)
    return resp


@app.exception_handler(HTTPException)
async def http_exc_handler(_req: Request, exc: HTTPException):
    logger.info(
        json.dumps(
            {
                "ts": int(time.time() * 1000),
                "level": "error",
                "event": "http_exception",
                "status": exc.status_code,
                "detail": exc.detail,
            }
        )
    )
    return JSONResponse(status_code=exc.status_code, content={"error": exc.detail})


@app.exception_handler(Exception)
async def unhandled_exc_handler(_req: Request, exc: Exception):
    logger.info(
        json.dumps(
            {
                "ts": int(time.time() * 1000),
                "level": "error",
                "event": "unhandled_exception",
                "error": str(exc),
            }
        )
    )
    return JSONResponse(status_code=500, content={"error": "internal_error"})


@app.get("/health")
def health():
    return {"status": "ok", "service": "forge-api"}


@app.get("/version")
def version():
    return {"version": APP_VERSION}
