from collections.abc import AsyncIterator
from contextlib import asynccontextmanager

import structlog
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from enqivra.api.evidence import router as evidence_router
from enqivra.api.health import router as health_router
from enqivra.api.investigations import router as investigations_router
from enqivra.api.knowledge import router as knowledge_router
from enqivra.api.lifecycle import router as lifecycle_router
from enqivra.api.twins import router as twins_router
from enqivra.core.config import get_settings
from enqivra.core.logging import configure_logging
from enqivra.core.middleware import ProductionMiddleware
from enqivra.repositories.connections import Connections
from enqivra.services.investigation import InvestigationService
from enqivra.services.knowledge import KnowledgeStore
from enqivra.services.lifecycle import ModelLifecycleService
from enqivra.services.twins import DigitalTwinService

settings = get_settings()
configure_logging(settings.log_level)
log = structlog.get_logger()


@asynccontextmanager
async def lifespan(app: FastAPI) -> AsyncIterator[None]:
    app.state.connections = Connections.create(settings)
    app.state.knowledge = KnowledgeStore(settings.intelligence_data_path)
    app.state.investigations = InvestigationService(app.state.knowledge)
    app.state.twins = DigitalTwinService(app.state.knowledge)
    app.state.lifecycle = ModelLifecycleService(app.state.knowledge)
    log.info("application_started", environment=settings.app_env)
    yield
    await app.state.connections.close()
    app.state.knowledge.close()
    log.info("application_stopped")


app = FastAPI(title=settings.app_name, version="0.1.0", lifespan=lifespan)
app.add_middleware(ProductionMiddleware, settings=settings)
app.add_middleware(
    CORSMiddleware,
    allow_origin_regex=r"https?://(localhost|127\.0\.0\.1)(:\d+)?",
    allow_methods=["GET", "POST", "OPTIONS"],
    allow_headers=["*"],
)
app.include_router(health_router, prefix="/api/v1")
app.include_router(evidence_router, prefix="/api/v1")
app.include_router(knowledge_router, prefix="/api/v1")
app.include_router(investigations_router, prefix="/api/v1")
app.include_router(twins_router, prefix="/api/v1")
app.include_router(lifecycle_router, prefix="/api/v1")
