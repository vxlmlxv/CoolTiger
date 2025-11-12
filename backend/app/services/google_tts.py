from __future__ import annotations

from typing import Annotated

from fastapi import Depends
from google.cloud import texttospeech


class GoogleTTSService:
    def __init__(self) -> None:
        self._client = texttospeech.TextToSpeechClient()

    def synthesize(self, text: str, language_code: str = "ko-KR") -> bytes:
        synthesis_input = texttospeech.SynthesisInput(text=text)
        voice = texttospeech.VoiceSelectionParams(language_code=language_code)
        audio_config = texttospeech.AudioConfig(audio_encoding=texttospeech.AudioEncoding.MP3)
        response = self._client.synthesize_speech(
            input=synthesis_input,
            voice=voice,
            audio_config=audio_config,
        )
        return response.audio_content


def get_google_tts_service() -> GoogleTTSService:
    return GoogleTTSService()


GoogleTTSDep = Annotated[GoogleTTSService, Depends(get_google_tts_service)]
