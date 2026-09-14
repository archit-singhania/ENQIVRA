# Intelligence API

FastAPI service for lifecycle-managed dependency health and Phase 3 local evidence analysis. `POST /api/v1/evidence/analyze` accepts images, PCM WAV audio, videos, and telemetry CSV files. Docker includes Tesseract OCR; direct Windows execution needs `tesseract.exe` on `PATH` for OCR and otherwise reports a truthful partial result.

Phase 4 adds local PDF/TXT/Markdown ingestion and grounded retrieval with page/chunk citations. Phase 5 adds persistent safety-triaged diagnostic investigations. Phases 6 and 7 add inspectable Bayesian-style evidence updates, next-best tests, ranked safe repair strategies, and repair-versus-replace factors. Host-mode state is stored under `data/intelligence.db`; Docker stores it in the `intelligence_data` volume.

Phase 8 adds per-asset digital-twin readings, health state, trends, threshold forecasts, and confidence/data-sufficiency reporting. Phase 9 adds the local model registry, evaluation/drift API, promotion gates, and a reproducible `dvc.yaml` pipeline. Run the lightweight evaluator with `python scripts/evaluate.py`. For DVC and local MLflow tracking, install `pip install -e ".[mlops]"`, then run `dvc repro`.

```powershell
.\.venv\Scripts\python.exe -m pip install -e ".[dev]"
.\.venv\Scripts\python.exe -m uvicorn enqivra.main:app --reload --port 8000
```

Open `http://localhost:8000/docs` for interactive API documentation.
