import httpx
from fastapi import APIRouter, HTTPException, Request

from enqivra.core.config import get_settings
from enqivra.schemas.investigation import (
    InvestigationView,
    ObservationRequest,
    StartInvestigation,
)

router = APIRouter(prefix="/investigations", tags=["diagnostic-investigations"])


@router.post("", response_model=InvestigationView)
async def start(request: Request, payload: StartInvestigation) -> InvestigationView:
    settings = get_settings()
    if settings.enforce_core_ownership:
        try:
            async with httpx.AsyncClient(timeout=3) as client:
                response = await client.get(
                    f"{settings.core_api_url}/cases/{payload.case_id}/evidence",
                    headers={"Authorization": request.headers.get("authorization", "")},
                )
            if response.status_code != 200:
                raise HTTPException(status_code=403, detail="Case access denied")
        except httpx.HTTPError as exc:
            raise HTTPException(status_code=503, detail="Core authorization unavailable") from exc
    return request.app.state.investigations.start(payload)


@router.get("/{identifier}", response_model=InvestigationView)
async def get(request: Request, identifier: str) -> InvestigationView:
    try:
        return request.app.state.investigations.get(identifier)
    except LookupError as exc:
        raise HTTPException(status_code=404, detail=str(exc)) from exc


@router.get("/by-case/{case_id}", response_model=InvestigationView | None)
async def by_case(request: Request, case_id: str) -> InvestigationView | None:
    return request.app.state.investigations.by_case(case_id)


@router.post("/{identifier}/observations", response_model=InvestigationView)
async def observe(
    request: Request, identifier: str, payload: ObservationRequest
) -> InvestigationView:
    try:
        return request.app.state.investigations.observe(identifier, payload.answer)
    except LookupError as exc:
        raise HTTPException(status_code=404, detail=str(exc)) from exc
    except ValueError as exc:
        raise HTTPException(status_code=409, detail=str(exc)) from exc


@router.post("/{identifier}/reason", response_model=InvestigationView)
async def analyze(request: Request, identifier: str) -> InvestigationView:
    try:
        return request.app.state.investigations.analyze(identifier)
    except LookupError as exc:
        raise HTTPException(status_code=404, detail=str(exc)) from exc
    except ValueError as exc:
        raise HTTPException(status_code=409, detail=str(exc)) from exc
