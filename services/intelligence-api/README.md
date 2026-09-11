# Intelligence API

FastAPI service for lifecycle-managed dependency health and Phase 3 local evidence analysis. `POST /api/v1/evidence/analyze` accepts images, PCM WAV audio, videos, and telemetry CSV files. Docker includes Tesseract OCR; direct Windows execution needs `tesseract.exe` on `PATH` for OCR and otherwise reports a truthful partial result.

Phase 4 adds local PDF/TXT/Markdown ingestion and grounded retrieval with page/chunk citations. Phase 5 adds persistent safety-triaged diagnostic investigations. Host-mode state is stored under `data/intelligence.db`; Docker stores it in the `intelligence_data` volume.

```powershell
.\.venv\Scripts\python.exe -m pip install -e ".[dev]"
.\.venv\Scripts\python.exe -m uvicorn enqivra.main:app --reload --port 8000
```

Open `http://localhost:8000/docs` for interactive API documentation.
