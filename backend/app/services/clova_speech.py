from __future__ import annotations

from email.mime import audio
import os
from typing import Annotated

import httpx
from fastapi import APIRouter, UploadFile, File, Form, Response, Depends, HTTPException, status 



class ClovaSpeechService:
    def __init__(self, base_url: str, api_key: str) -> None:
        self._base_url = base_url.rstrip('/')
        self._api_key = api_key

    async def transcribe(self, audio_url: str) -> dict[str, object]:
        async with httpx.AsyncClient() as client:
            await client.post(
                f"{self._base_url}/recognizer/url",
                headers={"Content-Type": "application/json", 
                        "X-CLOVASPEECH-API-KEY": self._api_key},
                json={"language": "ko-KR",
                    "completion":"async",
                    "url": audio_url,
                    "resultToObs" : 'true'
                }


            )
        return {"text": "stub transcript", "confidence": 0.9}


def get_clova_speech_service() -> ClovaSpeechService:
    base_url = os.getenv("CLOVA_SPEECH_BASE_URL")
    api_key = os.getenv("CLOVA_SPEECH_API_KEY")
    if not base_url or not api_key:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Missing CLOVA_SPEECH_BASE_URL or CLOVA_SPEECH_API_KEY env vars",
        )
    return ClovaSpeechService(base_url, api_key)


ClovaSpeechDep = Annotated[ClovaSpeechService, Depends(get_clova_speech_service)]
