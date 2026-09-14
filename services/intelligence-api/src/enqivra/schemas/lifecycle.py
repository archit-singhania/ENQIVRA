from datetime import datetime
from typing import Literal

from pydantic import BaseModel, Field


class EvaluationCase(BaseModel):
    complaint: str
    observations: list[str] = []
    domain: str | None = None
    expected_top_code: str


class EvaluationRequest(BaseModel):
    model_name: str = "diagnostic-rules"
    model_version: str = "1.0.0"
    dataset_version: str = "builtin-v1"
    cases: list[EvaluationCase] = Field(default_factory=list, max_length=1000)
    minimum_accuracy: float = Field(default=0.6, ge=0, le=1)


class EvaluationRun(BaseModel):
    id: str
    model_name: str
    model_version: str
    dataset_version: str
    metrics: dict[str, float]
    drift: dict[str, float | str]
    passed: bool
    created_at: datetime


class ModelVersion(BaseModel):
    model_name: str
    version: str
    stage: Literal["CANDIDATE", "STAGING", "PRODUCTION", "ARCHIVED"]
    algorithm: str
    parameters: dict
    metrics: dict[str, float]
    dataset_version: str
    created_at: datetime


class PromoteRequest(BaseModel):
    stage: Literal["STAGING", "PRODUCTION", "ARCHIVED"]
