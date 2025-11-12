from __future__ import annotations

from datetime import date

from pydantic import BaseModel

class AnalysisMetrics(BaseModel):
    sentiment: str
    word_count: int
    ttr: float
    speaking_rate: int

class AnalysisReport(BaseModel):
    id: str
    senior_id: str
    guardian_id: str
    date: date
    metrics: AnalysisMetrics
    summary: str
