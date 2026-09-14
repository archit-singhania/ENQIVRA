from typing import Literal

from pydantic import BaseModel


class Hypothesis(BaseModel):
    code: str
    title: str
    probability: float
    supporting_evidence: list[str]
    contradicting_evidence: list[str]


class DiagnosticTest(BaseModel):
    code: str
    question: str
    information_gain: float
    safety_level: Literal["GREEN", "YELLOW", "ORANGE", "RED"]


class RepairStrategy(BaseModel):
    rank: int
    title: str
    action: str
    strategy_type: Literal["DIY_CHECK", "SERVICE", "REPAIR", "REPLACE_CONSIDERATION"]
    safety_level: Literal["GREEN", "YELLOW", "ORANGE", "RED"]
    cost_band: Literal["LOW", "MEDIUM", "HIGH", "UNKNOWN"]
    rationale: str
    hypothesis_codes: list[str]
    requires_professional: bool


class ReasoningResult(BaseModel):
    hypotheses: list[Hypothesis]
    next_best_test: DiagnosticTest | None
    strategies: list[RepairStrategy]
    repair_vs_replace: str
    limitations: list[str]
