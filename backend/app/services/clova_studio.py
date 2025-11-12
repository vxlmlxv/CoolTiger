from __future__ import annotations

import os
from typing import Annotated

import httpx
from fastapi import Depends, HTTPException, status


class ClovaStudioService:
    def __init__(self, base_url: str, api_key: str) -> None:
        self._base_url = base_url.rstrip('/')
        self._api_key = api_key

    async def generate_reply(
        self,
        prompt: str,
        context: dict[str, object],
    ) -> dict[str, object]:
        async with httpx.AsyncClient() as client:
            await client.post(
                f"{self._base_url}/v3/chat-completions/HCX-005",
                headers={"Authorization": f"Bearer {self._api_key}",
                        "Content-Type": "application/json",
                        "Accept": "text/event-stream"},
                json={"prompt": prompt, "context": context},
            )
        return {
            "messages": [
        {
            "role": "system",
            "content": [
            {
                "type": "text",
                "text": "- 친절하게 답변하는 AI 어시스턴트입니다."
            }
        ]
        },
        {
            "role": "user",
            "content": [
            {
                "type": "text",
                "text": "노인을 위한 전화상담을 시작해줘"
            }
        ]
        }
    ]
        }


def get_clova_studio_service() -> ClovaStudioService:
    base_url = os.getenv("CLOVA_STUDIO_BASE_URL")
    api_key = os.getenv("CLOVA_STUDIO_API_KEY")
    if not base_url or not api_key:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Missing CLOVA_STUDIO_BASE_URL or CLOVA_STUDIO_API_KEY env vars",
        )
    return ClovaStudioService(base_url, api_key)


ClovaStudioDep = Annotated[ClovaStudioService, Depends(get_clova_studio_service)]
