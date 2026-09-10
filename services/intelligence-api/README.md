# Intelligence API

FastAPI integration boundary for future evidence analysis, retrieval, graph reasoning, and diagnostics. Phase 0 exposes lifecycle-managed dependency clients and health reporting only.

```bash
python -m venv .venv
pip install -e ".[dev]"
uvicorn enqivra.main:app --reload
pytest
ruff check src tests
```
