import json
import uuid
from datetime import UTC, datetime

from enqivra.schemas.lifecycle import EvaluationCase, EvaluationRequest, EvaluationRun, ModelVersion
from enqivra.services.knowledge import KnowledgeStore
from enqivra.services.reasoning import reason

BUILTIN_CASES = [
    EvaluationCase(
        complaint="Split AC is not cooling and airflow is weak",
        observations=["The filter is visibly blocked"],
        domain="HVAC",
        expected_top_code="hvac_filter",
    ),
    EvaluationCase(
        complaint="Car jerks with check engine light",
        observations=["Misfire under load"],
        domain="AUTOMOTIVE",
        expected_top_code="auto_ignition",
    ),
    EvaluationCase(
        complaint="Refrigerator is not cold and door has condensation",
        observations=["Door seal is loose"],
        domain="APPLIANCE",
        expected_top_code="appliance_seal",
    ),
    EvaluationCase(
        complaint="Equipment does not power on after outage",
        observations=["Breaker has tripped"],
        expected_top_code="power_supply",
    ),
]


class ModelLifecycleService:
    def __init__(self, store: KnowledgeStore) -> None:
        self.store = store

    def evaluate(self, request: EvaluationRequest) -> EvaluationRun:
        cases = request.cases or BUILTIN_CASES
        correct, confidences = 0, []
        for case in cases:
            observations = [
                {"question": "evaluation", "answer": value} for value in case.observations
            ]
            output = reason(case.complaint, observations, case.domain, "GREEN")
            correct += int(
                bool(output.hypotheses) and output.hypotheses[0].code == case.expected_top_code
            )
            confidences.append(output.hypotheses[0].probability if output.hypotheses else 0)
        accuracy = correct / len(cases) if cases else 0
        metrics = {
            "top_1_accuracy": round(accuracy, 4),
            "mean_top_confidence": round(sum(confidences) / len(confidences), 4),
            "case_count": float(len(cases)),
        }
        previous = self.store.connection.execute(
            "SELECT metrics_json FROM evaluation_runs WHERE model_name=? ORDER BY created_at DESC LIMIT 1",
            (request.model_name,),
        ).fetchone()
        previous_accuracy = (
            json.loads(previous["metrics_json"])["top_1_accuracy"] if previous else accuracy
        )
        drift = {
            "accuracy_delta": round(accuracy - previous_accuracy, 4),
            "status": "REGRESSION" if accuracy < previous_accuracy - 0.05 else "STABLE",
        }
        passed = accuracy >= request.minimum_accuracy and drift["status"] != "REGRESSION"
        identifier, now = str(uuid.uuid4()), datetime.now(UTC).isoformat()
        with self.store.lock, self.store.connection:
            self.store.connection.execute(
                "INSERT INTO evaluation_runs VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
                (
                    identifier,
                    request.model_name,
                    request.model_version,
                    request.dataset_version,
                    json.dumps(metrics),
                    json.dumps(drift),
                    int(passed),
                    now,
                ),
            )
            self.store.connection.execute(
                "INSERT OR REPLACE INTO model_versions VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)",
                (
                    str(uuid.uuid4()),
                    request.model_name,
                    request.model_version,
                    "CANDIDATE",
                    "transparent-bayesian-rules-v1",
                    json.dumps(
                        {"positive_likelihood_ratio": 2.4, "negative_likelihood_ratio": 2.8}
                    ),
                    json.dumps(metrics),
                    request.dataset_version,
                    now,
                ),
            )
        return EvaluationRun(
            id=identifier,
            model_name=request.model_name,
            model_version=request.model_version,
            dataset_version=request.dataset_version,
            metrics=metrics,
            drift=drift,
            passed=passed,
            created_at=datetime.fromisoformat(now),
        )

    def versions(self) -> list[ModelVersion]:
        rows = self.store.connection.execute(
            "SELECT * FROM model_versions ORDER BY created_at DESC"
        ).fetchall()
        return [
            ModelVersion(
                model_name=r["model_name"],
                version=r["version"],
                stage=r["stage"],
                algorithm=r["algorithm"],
                parameters=json.loads(r["parameters_json"]),
                metrics=json.loads(r["metrics_json"]),
                dataset_version=r["dataset_version"],
                created_at=datetime.fromisoformat(r["created_at"]),
            )
            for r in rows
        ]

    def promote(self, model_name: str, version: str, stage: str) -> ModelVersion:
        row = self.store.connection.execute(
            "SELECT * FROM model_versions WHERE model_name=? AND version=?", (model_name, version)
        ).fetchone()
        if not row:
            raise LookupError("Model version not found")
        metrics = json.loads(row["metrics_json"])
        if stage == "PRODUCTION" and metrics.get("top_1_accuracy", 0) < 0.6:
            raise ValueError("Quality gate failed: accuracy below 0.60")
        with self.store.lock, self.store.connection:
            if stage == "PRODUCTION":
                self.store.connection.execute(
                    "UPDATE model_versions SET stage='ARCHIVED' WHERE model_name=? AND stage='PRODUCTION'",
                    (model_name,),
                )
            self.store.connection.execute(
                "UPDATE model_versions SET stage=? WHERE model_name=? AND version=?",
                (stage, model_name, version),
            )
        return next(
            item
            for item in self.versions()
            if item.model_name == model_name and item.version == version
        )
