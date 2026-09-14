from fastapi import APIRouter, HTTPException, Request

from enqivra.schemas.lifecycle import EvaluationRequest, EvaluationRun, ModelVersion, PromoteRequest

router = APIRouter(prefix="/model-lifecycle", tags=["model-lifecycle"])


@router.post("/evaluations", response_model=EvaluationRun)
async def evaluate(request: Request, payload: EvaluationRequest) -> EvaluationRun:
    return request.app.state.lifecycle.evaluate(payload)


@router.get("/models", response_model=list[ModelVersion])
async def models(request: Request) -> list[ModelVersion]:
    return request.app.state.lifecycle.versions()


@router.post("/models/{model_name}/{version}/promote", response_model=ModelVersion)
async def promote(
    request: Request, model_name: str, version: str, payload: PromoteRequest
) -> ModelVersion:
    try:
        return request.app.state.lifecycle.promote(model_name, version, payload.stage)
    except LookupError as exc:
        raise HTTPException(status_code=404, detail=str(exc)) from exc
    except ValueError as exc:
        raise HTTPException(status_code=409, detail=str(exc)) from exc
