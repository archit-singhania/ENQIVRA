import math
import uuid
from collections import defaultdict
from datetime import UTC, datetime, timedelta

from enqivra.schemas.twin import DigitalTwinView, TwinPrediction, TwinSnapshot, TwinSnapshotRequest
from enqivra.services.knowledge import KnowledgeStore


class DigitalTwinService:
    def __init__(self, store: KnowledgeStore) -> None:
        self.store = store

    def record(self, asset_id: str, request: TwinSnapshotRequest) -> DigitalTwinView:
        recorded = request.recorded_at or datetime.now(UTC)
        identifier = str(uuid.uuid4())
        with self.store.lock, self.store.connection:
            self.store.connection.execute(
                "INSERT INTO twin_snapshots VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)",
                (
                    identifier,
                    asset_id,
                    request.metric.strip().lower(),
                    request.value,
                    request.unit.strip(),
                    request.warning_threshold,
                    request.critical_threshold,
                    recorded.isoformat(),
                    request.source,
                ),
            )
        return self.get(asset_id)

    def get(self, asset_id: str) -> DigitalTwinView:
        rows = self.store.connection.execute(
            "SELECT * FROM twin_snapshots WHERE asset_id=? ORDER BY recorded_at", (asset_id,)
        ).fetchall()
        groups = defaultdict(list)
        for row in rows:
            groups[row["metric"]].append(row)
        predictions = [_predict(metric, values) for metric, values in groups.items()]
        health = _health(predictions)
        snapshots = [
            TwinSnapshot(
                id=row["id"],
                metric=row["metric"],
                value=row["value"],
                unit=row["unit"],
                recorded_at=datetime.fromisoformat(row["recorded_at"]),
                source=row["source"],
            )
            for row in rows[-100:]
        ][::-1]
        return DigitalTwinView(
            asset_id=asset_id,
            health_index=health[0],
            health_state=health[1],
            snapshots=snapshots,
            predictions=predictions,
            updated_at=snapshots[0].recorded_at if snapshots else None,
        )


def _predict(metric: str, rows: list) -> TwinPrediction:
    latest = rows[-1]
    warning, critical = latest["warning_threshold"], latest["critical_threshold"]
    if len(rows) < 3:
        return TwinPrediction(
            metric=metric,
            state="INSUFFICIENT_DATA",
            trend_per_day=None,
            predicted_threshold_at=None,
            confidence=round(len(rows) / 3, 2),
            message="Record at least three time-separated readings for a trend forecast.",
        )
    times = [datetime.fromisoformat(row["recorded_at"]) for row in rows]
    origin = times[0]
    x = [
        max((item - origin).total_seconds() / 86400, index / 1440)
        for index, item in enumerate(times)
    ]
    y = [float(row["value"]) for row in rows]
    mean_x, mean_y = sum(x) / len(x), sum(y) / len(y)
    denominator = sum((value - mean_x) ** 2 for value in x)
    slope = (
        sum((xv - mean_x) * (yv - mean_y) for xv, yv in zip(x, y, strict=True)) / denominator
        if denominator
        else 0
    )
    fitted = [mean_y + slope * (value - mean_x) for value in x]
    error = math.sqrt(
        sum((actual - fit) ** 2 for actual, fit in zip(y, fitted, strict=True)) / len(y)
    )
    spread = max(max(y) - min(y), abs(mean_y), 1)
    confidence = min(0.95, max(0.2, (len(y) / (len(y) + 3)) * (1 - min(1, error / spread))))
    state = "NORMAL"
    if critical is not None and y[-1] >= critical:
        state = "CRITICAL"
    elif warning is not None and y[-1] >= warning:
        state = "WARNING"
    elif slope > 0 and warning is not None:
        state = "WATCH"
    target = critical if critical is not None else warning
    predicted = None
    if target is not None and slope > 0 and y[-1] < target:
        days = (target - y[-1]) / slope
        if 0 < days <= 3650:
            predicted = times[-1] + timedelta(days=days)
    message = f"Latest {y[-1]:g} {latest['unit']}; trend {slope:+.3g} {latest['unit']}/day."
    return TwinPrediction(
        metric=metric,
        state=state,
        trend_per_day=round(slope, 6),
        predicted_threshold_at=predicted,
        confidence=round(confidence, 3),
        message=message,
    )


def _health(predictions: list[TwinPrediction]) -> tuple[int, str]:
    if not predictions or all(item.state == "INSUFFICIENT_DATA" for item in predictions):
        return 0, "UNKNOWN"
    penalties = {"NORMAL": 0, "WATCH": 12, "WARNING": 30, "CRITICAL": 60, "INSUFFICIENT_DATA": 5}
    index = max(0, 100 - sum(penalties[item.state] for item in predictions))
    return (
        index,
        "CRITICAL"
        if index < 40
        else "SERVICE_DUE"
        if index < 70
        else "WATCH"
        if index < 90
        else "HEALTHY",
    )
