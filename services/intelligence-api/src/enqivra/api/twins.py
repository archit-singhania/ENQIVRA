from fastapi import APIRouter, Request

from enqivra.schemas.twin import DigitalTwinView, TwinSnapshotRequest

router = APIRouter(prefix="/twins", tags=["digital-twins"])


@router.get("/{asset_id}", response_model=DigitalTwinView)
async def get_twin(request: Request, asset_id: str) -> DigitalTwinView:
    return request.app.state.twins.get(asset_id)


@router.post("/{asset_id}/snapshots", response_model=DigitalTwinView)
async def record_snapshot(
    request: Request, asset_id: str, payload: TwinSnapshotRequest
) -> DigitalTwinView:
    return request.app.state.twins.record(asset_id, payload)
