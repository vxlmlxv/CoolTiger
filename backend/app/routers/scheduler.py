from __future__ import annotations

from fastapi import APIRouter, Depends

from ..services.firestore_client import FirestoreDep

router = APIRouter()

@router.post("/trigger-checkin")
async def trigger_checkin(db: FirestoreDep = Depends()) -> dict[str, str]:
    # TODO: implement scheduler logic
    _ = db
    return {"status": "scheduled"}
