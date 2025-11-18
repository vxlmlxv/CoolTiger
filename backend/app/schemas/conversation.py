from __future__ import annotations
from fastapi import APIRouter, UploadFile, File, Form, Response
from typing import Optional

from datetime import datetime
from enum import Enum

from pydantic import BaseModel


class ConversationSpeaker(str, Enum):
    user = "user"
    ai = "ai"

class ConversationLog(BaseModel):
    id: str
    senior_id: str
    guardian_id: str
    timestamp: datetime
    speaker: ConversationSpeaker
    transcript: str
    audio_url: str | None = None
    analysis_status: str = "pending"
