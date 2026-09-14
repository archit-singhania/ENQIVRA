import json
from pathlib import Path

from enqivra.schemas.lifecycle import EvaluationCase
from enqivra.services.reasoning import reason

root = Path(__file__).resolve().parents[1]
cases = [
    EvaluationCase.model_validate(item)
    for item in json.loads((root / "data/evaluation/reasoning_cases.json").read_text())
]
correct = 0
for case in cases:
    observations = [{"question": "evaluation", "answer": item} for item in case.observations]
    result = reason(case.complaint, observations, case.domain, "GREEN")
    correct += int(result.hypotheses[0].code == case.expected_top_code)
report = {"top_1_accuracy": correct / len(cases), "case_count": len(cases)}
(root / "reports").mkdir(exist_ok=True)
(root / "reports/evaluation.json").write_text(json.dumps(report, indent=2))
try:
    import mlflow

    mlflow.set_tracking_uri((root / "data/mlflow").as_uri())
    mlflow.set_experiment("enqivra-diagnostic-rules")
    with mlflow.start_run(run_name="dvc-evaluation"):
        mlflow.log_metrics(report)
        mlflow.log_artifact(root / "reports/evaluation.json")
        mlflow.log_artifact(root / "params.yaml")
except ImportError:
    pass
print(json.dumps(report))
