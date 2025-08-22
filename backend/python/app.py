from fastapi import FastAPI, Request
from uuid import uuid4
import time

app = FastAPI(title="Forge API", version="0.1.0")

@app.middleware("http")
async def add_request_id(request: Request, call_next):
    request_id = request.headers.get("x-request-id", str(uuid4()))
    start = time.time()
    response = await call_next(request)
    duration_ms = int((time.time() - start) * 1000)
    response.headers["x-request-id"] = request_id
    response.headers["x-duration-ms"] = str(duration_ms)
    return response

@app.get("/health")
def health():
    return {"status": "ok", "service": "forge-api"}
