from __future__ import annotations

from pydantic import BaseModel

class SeniorSettings(BaseModel):
    checkin_time: str
    proactive_call: bool = True

class Senior(BaseModel):
    id: str
    guardian_id: str
    name: str
    settings: SeniorSettings
    personal_history: dict[str, str | int | float | bool] | None = None
