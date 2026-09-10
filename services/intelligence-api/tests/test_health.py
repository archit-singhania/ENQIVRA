from unittest.mock import AsyncMock

from enqivra.services.health import health_report


async def test_health_report_returns_ok_when_all_dependencies_respond(monkeypatch):
    monkeypatch.setattr("enqivra.services.health._postgres_ok", AsyncMock(return_value=True))
    monkeypatch.setattr("enqivra.services.health._qdrant_ok", AsyncMock(return_value=True))
    monkeypatch.setattr("enqivra.services.health._neo4j_ok", AsyncMock(return_value=True))

    report = await health_report(AsyncMock())

    assert report.status == "ok"
    assert report.dependencies.postgres == "ok"
