from __future__ import annotations

from fastapi import APIRouter, Depends

from ..schemas import AnalysisReport
from ..services.firestore_client import FirestoreDep

router = APIRouter()

@router.get("/analysis/reports", response_model=list[AnalysisReport])
async def list_reports(guardian_id: str, db: FirestoreDep = Depends()):
    docs = db.collection("analysis_reports").where("guardianId", "==", guardian_id).stream()
    results: list[AnalysisReport] = []
    for doc in docs:
        payload = doc.to_dict()
        payload["id"] = doc.id
        results.append(AnalysisReport.model_validate(payload))
    return results
