import asyncio

from sqlalchemy import text

from enqivra.repositories.connections import Connections
from enqivra.schemas.health import DependencyStatus, HealthResponse


async def _postgres_ok(connections: Connections) -> bool:
    async with connections.postgres.connect() as connection:
        return (await connection.execute(text("select 1"))).scalar_one() == 1


async def _qdrant_ok(connections: Connections) -> bool:
    return await connections.qdrant.health_check()


async def _neo4j_ok(connections: Connections) -> bool:
    await connections.neo4j.verify_connectivity()
    return True


async def health_report(connections: Connections) -> HealthResponse:
    checks = await asyncio.gather(
        _postgres_ok(connections),
        _qdrant_ok(connections),
        _neo4j_ok(connections),
        return_exceptions=True,
    )
    values = [result is True for result in checks]
    dependencies = DependencyStatus(
        postgres="ok" if values[0] else "unavailable",
        qdrant="ok" if values[1] else "unavailable",
        neo4j="ok" if values[2] else "unavailable",
    )
    return HealthResponse(status="ok" if all(values) else "degraded", dependencies=dependencies)
