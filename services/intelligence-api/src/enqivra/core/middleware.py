import base64
import binascii
import hashlib
import hmac
import json
import re
import time
import uuid
from collections import defaultdict, deque

import httpx
import structlog
from fastapi import Request
from fastapi.responses import JSONResponse
from starlette.middleware.base import BaseHTTPMiddleware

from enqivra.core.config import Settings

log = structlog.get_logger()
PUBLIC = {"/api/v1/health", "/api/v1/ready", "/api/v1/metrics", "/docs", "/openapi.json", "/redoc"}
METRICS = {"requests_total": 0, "server_errors_total": 0}


class ProductionMiddleware(BaseHTTPMiddleware):
    def __init__(self, app, settings: Settings):
        super().__init__(app)
        self.settings = settings
        self.requests: dict[str, deque[float]] = defaultdict(deque)
        self.total = 0
        self.errors = 0

    async def dispatch(self, request: Request, call_next):
        started = time.perf_counter()
        request_id = request.headers.get("x-request-id", str(uuid.uuid4()))[:100]
        client = request.client.host if request.client else "unknown"
        now = time.monotonic()
        bucket = self.requests[client]
        while bucket and bucket[0] < now - 60:
            bucket.popleft()
        if len(bucket) >= self.settings.rate_limit_per_minute:
            return self._error(429, "Rate limit exceeded", request_id)
        bucket.append(now)
        size = int(request.headers.get("content-length", "0") or 0)
        if size > self.settings.max_request_bytes:
            return self._error(413, "Request is too large", request_id)
        token = request.headers.get("authorization", "")
        if self.settings.auth_required and request.url.path not in PUBLIC:
            subject = _validate_token(token, self.settings.jwt_secret)
            if not subject:
                return self._error(401, "Valid bearer token required", request_id)
            request.state.user_id = subject
            if self.settings.enforce_core_ownership and not await self._owns_resource(
                request, token
            ):
                return self._error(403, "Resource access denied", request_id)
        self.total += 1
        METRICS["requests_total"] += 1
        response = await call_next(request)
        self.errors += int(response.status_code >= 500)
        METRICS["server_errors_total"] += int(response.status_code >= 500)
        response.headers["X-Request-ID"] = request_id
        response.headers["X-Content-Type-Options"] = "nosniff"
        response.headers["X-Frame-Options"] = "DENY"
        response.headers["Referrer-Policy"] = "no-referrer"
        response.headers["Permissions-Policy"] = "camera=(), microphone=(), geolocation=()"
        response.headers["Cache-Control"] = "no-store"
        log.info(
            "request_completed",
            request_id=request_id,
            method=request.method,
            path=request.url.path,
            status=response.status_code,
            duration_ms=round((time.perf_counter() - started) * 1000, 2),
        )
        return response

    def _error(self, status: int, message: str, request_id: str):
        response = JSONResponse({"detail": message, "request_id": request_id}, status_code=status)
        response.headers["X-Request-ID"] = request_id
        return response

    async def _owns_resource(self, request: Request, token: str) -> bool:
        twin = re.match(r"/api/v1/twins/([^/]+)", request.url.path)
        investigation = re.match(r"/api/v1/investigations(?:/by-case)?/([^/]+)", request.url.path)
        path = f"/assets/{twin.group(1)}/components" if twin else None
        if investigation and "by-case" in request.url.path:
            path = f"/cases/{investigation.group(1)}/evidence"
        elif investigation:
            try:
                row = request.app.state.knowledge.connection.execute(
                    "SELECT case_id FROM investigations WHERE id=?", (investigation.group(1),)
                ).fetchone()
                if row:
                    path = f"/cases/{row['case_id']}/evidence"
            except Exception:
                return False
        if not path:
            return True
        try:
            async with httpx.AsyncClient(timeout=3) as client:
                response = await client.get(
                    self.settings.core_api_url + path, headers={"Authorization": token}
                )
            return response.status_code == 200
        except httpx.HTTPError:
            return False


def _validate_token(header: str, secret: str) -> str | None:
    if not header.startswith("Bearer ") or len(secret) < 32:
        return None
    try:
        token = header[7:]
        encoded_header, encoded_payload, signature = token.split(".")
        unsigned = f"{encoded_header}.{encoded_payload}".encode()
        expected = hmac.new(secret.encode(), unsigned, hashlib.sha256).digest()
        supplied = base64.urlsafe_b64decode(signature + "=" * (-len(signature) % 4))
        if not hmac.compare_digest(expected, supplied):
            return None
        payload = json.loads(
            base64.urlsafe_b64decode(encoded_payload + "=" * (-len(encoded_payload) % 4))
        )
        if payload.get("exp", 0) <= time.time():
            return None
        return str(payload["sub"])
    except (ValueError, KeyError, json.JSONDecodeError, binascii.Error):
        return None
