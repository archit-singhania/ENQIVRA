import math
from dataclasses import dataclass

from enqivra.schemas.reasoning import (
    DiagnosticTest,
    Hypothesis,
    ReasoningResult,
    RepairStrategy,
)


@dataclass(frozen=True)
class Rule:
    code: str
    title: str
    prior: float
    positive: tuple[str, ...]
    negative: tuple[str, ...]
    test_code: str
    test_question: str
    action: str
    strategy_type: str
    safety: str
    cost: str
    professional: bool = False


COMMON = (
    Rule(
        "power_supply",
        "Power supply or protection issue",
        0.20,
        ("no power", "won't start", "does not power", "outage", "breaker"),
        ("powers on", "running"),
        "verify_power",
        "With no exposed conductors, is the outlet/supply available and has a breaker or protection device tripped?",
        "Verify the external supply, plug, and user-resettable protection without opening live panels.",
        "DIY_CHECK",
        "YELLOW",
        "LOW",
    ),
    Rule(
        "control_setting",
        "Control, setting, or sensor input issue",
        0.16,
        ("error code", "setting", "intermittent", "after warming"),
        (),
        "record_code",
        "What exact indicator or error code is displayed?",
        "Record the exact code and restore documented user settings; use the cited service documentation for further testing.",
        "DIY_CHECK",
        "GREEN",
        "LOW",
    ),
    Rule(
        "mechanical_wear",
        "Mechanical wear or obstruction",
        0.18,
        ("noise", "humming", "vibration", "blocked", "obstruction"),
        ("quiet",),
        "inspect_obstruction",
        "With power isolated, is any user-accessible intake, outlet, or moving path visibly obstructed?",
        "Isolate power and inspect only user-serviceable paths for visible obstruction; otherwise arrange service.",
        "SERVICE",
        "YELLOW",
        "MEDIUM",
        True,
    ),
)

HVAC = (
    Rule(
        "hvac_filter",
        "Restricted filter or airflow",
        0.34,
        ("not cooling", "poor cooling", "filter", "airflow", "after five", "powers on"),
        ("no power",),
        "check_filter",
        "With power isolated, is the user-serviceable indoor filter visibly dirty or obstructed?",
        "Isolate power and clean or replace the documented user-serviceable filter, then verify airflow.",
        "REPAIR",
        "GREEN",
        "LOW",
    ),
    Rule(
        "hvac_fan",
        "Indoor or outdoor fan fault",
        0.22,
        ("not cooling", "humming", "fan", "low airflow"),
        ("both fans operate",),
        "observe_fans",
        "From a safe distance, do both indoor and outdoor fans operate while cooling is requested?",
        "Arrange qualified HVAC inspection of the non-operating fan, controls, and motor circuit.",
        "SERVICE",
        "ORANGE",
        "MEDIUM",
        True,
    ),
    Rule(
        "hvac_sealed_system",
        "Compressor or sealed refrigerant-system fault",
        0.14,
        ("not cooling", "compressor", "refrigerant", "humming", "overheat"),
        ("filter blocked",),
        "temperature_delta",
        "Without opening panels, is there a clear temperature difference between return and supply air?",
        "Stop DIY work and arrange a qualified sealed-system and electrical diagnosis.",
        "SERVICE",
        "ORANGE",
        "HIGH",
        True,
    ),
)

AUTOMOTIVE = (
    Rule(
        "auto_ignition",
        "Ignition misfire",
        0.28,
        ("misfire", "jerk", "rough", "check engine", "under load"),
        (),
        "obd_codes",
        "What exact OBD-II codes or dashboard warnings are present?",
        "Arrange code-guided ignition diagnosis; replace parts only after confirming the failed component.",
        "SERVICE",
        "YELLOW",
        "MEDIUM",
        True,
    ),
    Rule(
        "auto_air_fuel",
        "Air, fuel, or metering fault",
        0.22,
        ("power loss", "stall", "lean", "fuel", "jerk"),
        (),
        "operating_condition",
        "At what speed, load, and temperature does the symptom occur?",
        "Arrange professional air/fuel measurement and leak testing before replacing components.",
        "SERVICE",
        "ORANGE",
        "MEDIUM",
        True,
    ),
)

APPLIANCE = (
    Rule(
        "appliance_seal",
        "Door seal or heat leakage",
        0.30,
        ("door", "seal", "not cold", "condensation", "frost"),
        (),
        "paper_test",
        "With no electrical access, does the closed door grip a strip of paper consistently around the seal?",
        "Clean and inspect the door seal; replace it if visibly damaged and confirmed not to seal.",
        "REPAIR",
        "GREEN",
        "LOW",
    ),
    Rule(
        "appliance_airflow",
        "Internal airflow obstruction",
        0.24,
        ("not cold", "frost", "blocked", "fan"),
        (),
        "vent_check",
        "Are internal vents visibly blocked by contents or ice?",
        "Clear documented ventilation space; persistent ice or fan faults require appliance service.",
        "SERVICE",
        "YELLOW",
        "MEDIUM",
        True,
    ),
)


def reason(
    complaint: str, observations: list[dict[str, str]], domain: str | None, safety: str
) -> ReasoningResult:
    text = " ".join([complaint, *(item["answer"] for item in observations)]).lower()
    if not domain:
        if any(token in text for token in (" ac ", "air conditioner", "cooling", "hvac")):
            domain = "HVAC"
        elif any(token in text for token in ("car", "engine", "vehicle", "obd", "brake")):
            domain = "AUTOMOTIVE"
        elif any(token in text for token in ("fridge", "refrigerator", "freezer", "appliance")):
            domain = "APPLIANCE"
    rules = list(COMMON)
    if (domain or "").upper() == "HVAC":
        rules += HVAC
    elif (domain or "").upper() == "AUTOMOTIVE":
        rules += AUTOMOTIVE
    elif (domain or "").upper() == "APPLIANCE":
        rules += APPLIANCE
    scores: list[tuple[Rule, float, list[str], list[str]]] = []
    for rule in rules:
        support = [token for token in rule.positive if token in text]
        contradict = [token for token in rule.negative if token in text]
        log_odds = (
            math.log(rule.prior / (1 - rule.prior))
            + len(support) * math.log(2.4)
            - len(contradict) * math.log(2.8)
        )
        scores.append((rule, 1 / (1 + math.exp(-log_odds)), support, contradict))
    total = sum(item[1] for item in scores) or 1
    ranked = sorted(scores, key=lambda item: item[1], reverse=True)
    hypotheses = [
        Hypothesis(
            code=r.code,
            title=r.title,
            probability=round(p / total, 4),
            supporting_evidence=s,
            contradicting_evidence=c,
        )
        for r, p, s, c in ranked
    ]
    asked = " ".join(item["question"] for item in observations).lower()
    candidate = next(
        (
            item
            for item in ranked
            if item[0].test_question.lower() not in asked and item[1] / total > 0.08
        ),
        None,
    )
    next_test = (
        None
        if candidate is None
        else DiagnosticTest(
            code=candidate[0].test_code,
            question=candidate[0].test_question,
            information_gain=round(4 * (candidate[1] / total) * (1 - candidate[1] / total), 4),
            safety_level="GREEN" if candidate[0].safety == "GREEN" else "YELLOW",
        )
    )
    strategies = []
    for rank, (rule, probability, _, _) in enumerate(ranked[:3], 1):
        normalized = probability / total
        if normalized < 0.08:
            continue
        strategies.append(
            RepairStrategy(
                rank=rank,
                title=rule.title,
                action=rule.action,
                strategy_type=rule.strategy_type,
                safety_level=rule.safety,
                cost_band=rule.cost,
                rationale=f"Associated hypothesis probability {normalized:.1%}; verify before replacing parts.",
                hypothesis_codes=[rule.code],
                requires_professional=rule.professional or safety == "ORANGE",
            )
        )
    top = hypotheses[0].probability if hypotheses else 0
    replace = "Repair-first is reasonable when inspection confirms a low-cost, user-serviceable cause. Consider replacement only when a qualified estimate is high relative to an equivalent unit, failures recur, critical parts are unavailable, or safety/reliability remains poor."
    limitations = [
        "Probabilities are normalized rule-based estimates, not failure proof.",
        "No parts should be replaced solely from this ranking.",
        "Exact repair-versus-replace economics require asset age, condition, local quotes, parts availability, and replacement price.",
    ]
    if top < 0.45:
        limitations.append(
            "Evidence is not decisive; perform the next safe test or obtain professional measurements."
        )
    return ReasoningResult(
        hypotheses=hypotheses,
        next_best_test=next_test,
        strategies=strategies,
        repair_vs_replace=replace,
        limitations=limitations,
    )
