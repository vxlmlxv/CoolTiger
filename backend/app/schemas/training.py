from __future__ import annotations

from enum import Enum

from pydantic import BaseModel

class TrainingModuleType(str, Enum):
    card_match = "card_match"
    memory_recall = "memory_recall"
    custom = "custom"

class TrainingModuleResponse(BaseModel):
    type: str
    tts_audio_url: str
    tts_prompt: str
    module_type: TrainingModuleType
    module_data: dict[str, object]
    module_id: str | None = None
