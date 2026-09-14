from datetime import UTC, datetime, timedelta
from pathlib import Path

from enqivra.schemas.twin import TwinSnapshotRequest
from enqivra.services.knowledge import KnowledgeStore
from enqivra.services.twins import DigitalTwinService


def test_twin_builds_trend_and_threshold_forecast(tmp_path: Path):
    store = KnowledgeStore(str(tmp_path / "twins.db"))
    service = DigitalTwinService(store)
    start = datetime(2026, 1, 1, tzinfo=UTC)
    for day, value in enumerate((50.0, 60.0, 70.0)):
        twin = service.record(
            "asset-1",
            TwinSnapshotRequest(
                metric="temperature",
                value=value,
                unit="C",
                warning_threshold=80,
                critical_threshold=90,
                recorded_at=start + timedelta(days=day),
            ),
        )
    assert twin.health_state == "WATCH"
    assert twin.predictions[0].trend_per_day == 10
    assert twin.predictions[0].predicted_threshold_at == start + timedelta(days=4)
    assert twin.predictions[0].confidence > 0
    store.close()


def test_sparse_twin_is_honest(tmp_path: Path):
    store = KnowledgeStore(str(tmp_path / "sparse.db"))
    twin = DigitalTwinService(store).record(
        "asset-2", TwinSnapshotRequest(metric="vibration", value=2, unit="mm/s")
    )
    assert twin.health_state == "UNKNOWN"
    assert twin.predictions[0].state == "INSUFFICIENT_DATA"
    store.close()
