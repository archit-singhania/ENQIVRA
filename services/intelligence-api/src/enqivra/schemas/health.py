from typing import Literal

from pydantic import BaseModel


class DependencyStatus(BaseModel):
    postgres: Literal["ok", "unavailable"]
    qdrant: Literal["ok", "unavailable"]
    neo4j: Literal["ok", "unavailable"]


class HealthResponse(BaseModel):
    service: str = "intelligence-api"
    status: Literal["ok", "degraded"]
    dependencies: DependencyStatus
