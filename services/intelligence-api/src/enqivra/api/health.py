from fastapi import APIRouter, Request

from enqivra.schemas.health import HealthResponse
from enqivra.services.health import health_report

router = APIRouter(tags=["platform"])


@router.get("/health", response_model=HealthResponse)
async def health(request: Request) -> HealthResponse:
    return await health_report(request.app.state.connections)
