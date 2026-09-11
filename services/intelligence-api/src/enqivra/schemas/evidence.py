from typing import Any, Literal

from pydantic import BaseModel, Field


class Signal(BaseModel):
    name: str
    value: Any
    unit: str | None = None


class AnalysisResult(BaseModel):
    analyzer: str
    analyzer_version: str = "phase3-1"
    evidence_type: Literal["IMAGE", "AUDIO", "VIDEO", "TELEMETRY"]
    status: Literal["COMPLETED", "PARTIAL", "UNSUPPORTED"]
    signals: list[Signal] = Field(default_factory=list)
    observations: list[str] = Field(default_factory=list)
    extracted_text: str | None = None
    equipment_candidates: list[str] = Field(default_factory=list)
    limitations: list[str] = Field(default_factory=list)
