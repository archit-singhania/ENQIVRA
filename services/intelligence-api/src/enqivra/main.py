from collections.abc import AsyncIterator
from contextlib import asynccontextmanager

import structlog
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from enqivra.api.evidence import router as evidence_router
from enqivra.api.health import router as health_router
from enqivra.core.config import get_settings
from enqivra.core.logging import configure_logging
from enqivra.repositories.connections import Connections

settings = get_settings()
configure_logging(settings.log_level)
log = structlog.get_logger()


@asynccontextmanager
async def lifespan(app: FastAPI) -> AsyncIterator[None]:
    app.state.connections = Connections.create(settings)
    log.info("application_started", environment=settings.app_env)
    yield
    await app.state.connections.close()
    log.info("application_stopped")


app = FastAPI(title=settings.app_name, version="0.1.0", lifespan=lifespan)
app.add_middleware(
    CORSMiddleware,
    allow_origin_regex=r"https?://(localhost|127\.0\.0\.1)(:\d+)?",
    allow_methods=["GET", "POST", "OPTIONS"],
    allow_headers=["*"],
)
app.include_router(health_router, prefix="/api/v1")
app.include_router(evidence_router, prefix="/api/v1")
