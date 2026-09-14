from pathlib import Path

from enqivra.schemas.lifecycle import EvaluationRequest
from enqivra.services.knowledge import KnowledgeStore
from enqivra.services.lifecycle import ModelLifecycleService


def test_evaluation_registry_and_promotion_gate(tmp_path: Path):
    store = KnowledgeStore(str(tmp_path / "models.db"))
    service = ModelLifecycleService(store)
    run = service.evaluate(EvaluationRequest())
    assert run.passed
    assert run.metrics["top_1_accuracy"] >= 0.75
    assert service.versions()[0].stage == "CANDIDATE"
    promoted = service.promote("diagnostic-rules", "1.0.0", "PRODUCTION")
    assert promoted.stage == "PRODUCTION"
    store.close()
