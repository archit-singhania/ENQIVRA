from typing import Annotated

from fastapi import APIRouter, File, Form, HTTPException, UploadFile

from enqivra.schemas.evidence import AnalysisResult
from enqivra.services.evidence import analyze

router = APIRouter(prefix="/evidence", tags=["evidence-intelligence"])


@router.post("/analyze", response_model=AnalysisResult)
async def analyze_evidence(
    evidence_type: Annotated[str, Form()], file: Annotated[UploadFile, File()]
) -> AnalysisResult:
    try:
        return analyze(evidence_type, await file.read(), file.filename or "evidence")
    except (ValueError, OSError) as exc:
        raise HTTPException(status_code=422, detail=str(exc)) from exc
