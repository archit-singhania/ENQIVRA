from datetime import datetime
from typing import Literal

from pydantic import BaseModel, Field


class TwinSnapshotRequest(BaseModel):
    metric: str = Field(min_length=1, max_length=100)
    value: float
    unit: str = Field(min_length=1, max_length=40)
    warning_threshold: float | None = None
    critical_threshold: float | None = None
    recorded_at: datetime | None = None
    source: str = Field(default="MANUAL", max_length=80)


class TwinSnapshot(BaseModel):
    id: str
    metric: str
    value: float
    unit: str
    recorded_at: datetime
    source: str


class TwinPrediction(BaseModel):
    metric: str
    state: Literal["NORMAL", "WATCH", "WARNING", "CRITICAL", "INSUFFICIENT_DATA"]
    trend_per_day: float | None
    predicted_threshold_at: datetime | None
    confidence: float
    message: str


class DigitalTwinView(BaseModel):
    asset_id: str
    health_index: int
    health_state: Literal["HEALTHY", "WATCH", "SERVICE_DUE", "CRITICAL", "UNKNOWN"]
    snapshots: list[TwinSnapshot]
    predictions: list[TwinPrediction]
    updated_at: datetime | None
