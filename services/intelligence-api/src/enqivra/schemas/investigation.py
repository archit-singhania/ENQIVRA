from datetime import datetime
from typing import Literal

from pydantic import BaseModel, Field

from enqivra.schemas.knowledge import Citation


class StartInvestigation(BaseModel):
    case_id: str
    complaint: str = Field(min_length=3, max_length=5000)
    domain: str | None = None
    equipment_code: str | None = None


class ObservationRequest(BaseModel):
    answer: str = Field(min_length=1, max_length=5000)


class InvestigationView(BaseModel):
    id: str
    case_id: str
    complaint: str
    status: Literal["AWAITING_OBSERVATION", "STOPPED_SAFETY", "READY_FOR_REASONING"]
    safety_level: Literal["GREEN", "YELLOW", "ORANGE", "RED"]
    safety_message: str | None
    current_question: str | None
    observations: list[dict[str, str]]
    evidence_summary: str
    citations: list[Citation]
    created_at: datetime
    updated_at: datetime
