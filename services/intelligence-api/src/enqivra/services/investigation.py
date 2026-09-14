import json
import re
import uuid
from datetime import UTC, datetime

from enqivra.schemas.investigation import InvestigationView, StartInvestigation
from enqivra.services.knowledge import KnowledgeStore
from enqivra.services.reasoning import reason

QUESTIONS = [
    ("power", "Does the equipment power on, and are any indicators or error codes visible?"),
    ("timing", "When does the symptom begin: immediately, after warming up, or intermittently?"),
    (
        "sound",
        "With no unsafe contact, what abnormal sound, smell, vibration, or heat do you observe?",
    ),
    (
        "change",
        "What changed shortly before the problem: service, impact, outage, weather, or settings?",
    ),
]

RED_PATTERNS = {
    r"gas.{0,20}(leak|smell)|smell.{0,20}gas": "Potential gas leak. Move away, avoid switches or flames, and contact emergency or authorized gas services.",
    r"smoke|on fire|flames": "Smoke or fire reported. Stop the workflow, move to safety, and contact emergency services.",
    r"live wire|exposed wire|high voltage|electric shock": "Potential live electrical hazard. Do not touch the equipment; isolate only if safe and contact a qualified electrician.",
    r"brake.*fail|steering.*fail": "Potential vehicle control failure. Do not drive; arrange professional recovery and inspection.",
}
ORANGE_PATTERN = re.compile(r"overheat|burning smell|refrigerant|pressure|compressor|sparks?", re.I)


class InvestigationService:
    def __init__(self, store: KnowledgeStore) -> None:
        self.store = store

    def start(self, request: StartInvestigation) -> InvestigationView:
        existing = self.store.connection.execute(
            "SELECT * FROM investigations WHERE case_id = ?", (request.case_id,)
        ).fetchone()
        if existing:
            return _view(existing)
        level, message = _safety(request.complaint)
        preliminary = reason(request.complaint, [], request.domain, level)
        question = (
            None
            if level == "RED" or preliminary.next_best_test is None
            else preliminary.next_best_test.question
        )
        status = "STOPPED_SAFETY" if level == "RED" else "AWAITING_OBSERVATION"
        knowledge = self.store.answer(
            request.complaint, request.domain, request.equipment_code, limit=4
        )
        now = datetime.now(UTC).isoformat()
        identifier = str(uuid.uuid4())
        with self.store.lock, self.store.connection:
            self.store.connection.execute(
                "INSERT INTO investigations (id, case_id, complaint, domain, equipment_code, status, safety_level, safety_message, current_question, observations_json, evidence_summary, citations_json, created_at, updated_at, reasoning_json) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
                (
                    identifier,
                    request.case_id,
                    request.complaint,
                    request.domain,
                    request.equipment_code,
                    status,
                    level,
                    message,
                    question,
                    "[]",
                    knowledge.answer,
                    json.dumps([item.model_dump(mode="json") for item in knowledge.citations]),
                    now,
                    now,
                    (None if level == "RED" else json.dumps(preliminary.model_dump(mode="json"))),
                ),
            )
        return self.get(identifier)

    def analyze(self, identifier: str) -> InvestigationView:
        row = self._row(identifier)
        if row["status"] == "STOPPED_SAFETY":
            raise ValueError("Safety-stopped investigations cannot be analyzed for DIY repair")
        if row["status"] not in {"READY_FOR_REASONING", "ANALYZED"}:
            raise ValueError("Complete the evidence questions before diagnostic reasoning")
        result = reason(
            row["complaint"],
            json.loads(row["observations_json"]),
            row["domain"],
            row["safety_level"],
        )
        with self.store.lock, self.store.connection:
            self.store.connection.execute(
                "UPDATE investigations SET status='ANALYZED', reasoning_json=?, updated_at=? WHERE id=?",
                (
                    json.dumps(result.model_dump(mode="json")),
                    datetime.now(UTC).isoformat(),
                    identifier,
                ),
            )
        return self.get(identifier)

    def observe(self, identifier: str, answer: str) -> InvestigationView:
        row = self._row(identifier)
        if row["status"] == "STOPPED_SAFETY":
            raise ValueError("Safety-stopped investigations cannot accept DIY observations")
        observations = json.loads(row["observations_json"])
        observations.append({"question": row["current_question"], "answer": answer.strip()})
        combined = row["complaint"] + " " + " ".join(item["answer"] for item in observations)
        level, message = _safety(combined)
        if level == "RED":
            status, question, reasoning_result = "STOPPED_SAFETY", None, None
        else:
            reasoning_result = reason(row["complaint"], observations, row["domain"], level)
            question = (
                reasoning_result.next_best_test.question
                if len(observations) < 4 and reasoning_result.next_best_test
                else None
            )
            status = "AWAITING_OBSERVATION" if question else "READY_FOR_REASONING"
        knowledge = self.store.answer(combined, row["domain"], row["equipment_code"], limit=4)
        with self.store.lock, self.store.connection:
            self.store.connection.execute(
                "UPDATE investigations SET status=?, safety_level=?, safety_message=?, current_question=?, observations_json=?, evidence_summary=?, citations_json=?, reasoning_json=?, updated_at=? WHERE id=?",
                (
                    status,
                    level,
                    message,
                    question,
                    json.dumps(observations),
                    knowledge.answer,
                    json.dumps([item.model_dump(mode="json") for item in knowledge.citations]),
                    (
                        json.dumps(reasoning_result.model_dump(mode="json"))
                        if reasoning_result
                        else None
                    ),
                    datetime.now(UTC).isoformat(),
                    identifier,
                ),
            )
        return self.get(identifier)

    def get(self, identifier: str) -> InvestigationView:
        return _view(self._row(identifier))

    def by_case(self, case_id: str) -> InvestigationView | None:
        row = self.store.connection.execute(
            "SELECT * FROM investigations WHERE case_id = ?", (case_id,)
        ).fetchone()
        return _view(row) if row else None

    def _row(self, identifier: str):
        row = self.store.connection.execute(
            "SELECT * FROM investigations WHERE id = ?", (identifier,)
        ).fetchone()
        if not row:
            raise LookupError("Investigation not found")
        return row


def _safety(text: str) -> tuple[str, str | None]:
    for pattern, message in RED_PATTERNS.items():
        if re.search(pattern, text, re.I):
            return "RED", message
    if ORANGE_PATTERN.search(text):
        return (
            "ORANGE",
            "Professional inspection is recommended; continue with non-invasive observations only.",
        )
    return "GREEN", None


def _next_question(observations: list[dict[str, str]]) -> str | None:
    asked = {item["question"] for item in observations}
    return next((question for _, question in QUESTIONS if question not in asked), None)


def _view(row) -> InvestigationView:
    return InvestigationView(
        id=row["id"],
        case_id=row["case_id"],
        complaint=row["complaint"],
        status=row["status"],
        safety_level=row["safety_level"],
        safety_message=row["safety_message"],
        current_question=row["current_question"],
        observations=json.loads(row["observations_json"]),
        evidence_summary=row["evidence_summary"],
        citations=json.loads(row["citations_json"]),
        reasoning=(
            json.loads(row["reasoning_json"])
            if "reasoning_json" in row.keys() and row["reasoning_json"]
            else None
        ),
        created_at=datetime.fromisoformat(row["created_at"]),
        updated_at=datetime.fromisoformat(row["updated_at"]),
    )
