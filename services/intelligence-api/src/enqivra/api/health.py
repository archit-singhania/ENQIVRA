from fastapi import APIRouter, Request, Response

from enqivra.core.middleware import METRICS
from enqivra.schemas.health import HealthResponse
from enqivra.services.health import health_report

router = APIRouter(tags=["platform"])


@router.get("/health", response_model=HealthResponse)
async def health(request: Request) -> HealthResponse:
    return await health_report(request.app.state.connections)


@router.get("/ready")
async def ready(request: Request) -> dict[str, str]:
    request.app.state.knowledge.connection.execute("SELECT 1").fetchone()
    return {"status": "ready"}


@router.get("/metrics", response_class=Response)
async def metrics() -> Response:
    body = "\n".join(f"enqivra_{name} {value}" for name, value in METRICS.items()) + "\n"
    return Response(body, media_type="text/plain; version=0.0.4")
