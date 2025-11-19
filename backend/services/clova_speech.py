"""
Naver CLOVA Speech-to-Text service wrapper.

This module provides functions to transcribe audio using Naver's CLOVA Speech API.
It handles API authentication, request formatting, and response parsing.
"""

import logging
from typing import Any

import httpx

from config import settings

# Configure logger
logger = logging.getLogger(__name__)


class ClovaSpeechError(Exception):
    """Custom exception for CLOVA Speech API errors."""
    pass


def transcribe_audio(audio_bytes: bytes, mime_type: str = "audio/wav") -> str:
    """
    Transcribe audio to text using Naver CLOVA Speech API.
    
    Sends audio data to the CLOVA Speech endpoint and returns the recognized text.
    Handles authentication, request formatting, and error handling.
    
    Args:
        audio_bytes: Raw audio data as bytes
        mime_type: MIME type of the audio (default: "audio/wav")
                  Common values: "audio/wav", "audio/mp3", "audio/mpeg", "audio/ogg"
    
    Returns:
        str: The transcribed text from the audio
        
    Raises:
        ClovaSpeechError: If the API request fails or returns an error
        ValueError: If required configuration is missing
        
    Example:
        >>> with open("audio.wav", "rb") as f:
        ...     audio_data = f.read()
        >>> transcript = transcribe_audio(audio_data, mime_type="audio/wav")
        >>> print(f"Recognized: {transcript}")
    """
    # Validate required configuration
    if not settings.clova_speech_endpoint:
        logger.error("CLOVA Speech endpoint is not configured")
        raise ValueError("CLOVA Speech endpoint is not configured in settings")
    
    if not settings.clova_speech_api_key:
        logger.error("CLOVA Speech API key is not configured")
        raise ValueError("CLOVA Speech API key is not configured in settings")
    
    if not settings.clova_speech_secret:
        logger.error("CLOVA Speech secret is not configured")
        raise ValueError("CLOVA Speech secret is not configured in settings")
    
    logger.info(f"Starting audio transcription with CLOVA Speech (mime_type: {mime_type})")
    

    headers = {
        "X-CLOVASPEECH-API-KEY": settings.clova_speech_api_key,  
        "Content-Type": 'multipart/form-data',
    }
    
    body = {
        "media": audio_bytes,
        "params":{
            "language": "ko-KR",
            "completion":"sync"
        }
    }

    try:
        # Send POST request to CLOVA Speech endpoint
        logger.debug(f"Sending request to {settings.clova_speech_endpoint}")
        
        with httpx.Client(timeout=30.0) as client:
            response = client.post(
                settings.clova_speech_endpoint + "/recognizer/upload",
                headers=headers,
                content=body,
            )
        
        # Log response status
        logger.info(f"CLOVA Speech API response status: {response.status_code}")
        
        # Handle HTTP errors
        if response.status_code != 200:
            error_message = f"CLOVA Speech API error: {response.status_code}"
            try:
                error_data = response.json()
                error_message += f" - {error_data}"
                logger.error(f"API error response: {error_data}")
            except Exception:
                error_message += f" - {response.text}"
                logger.error(f"API error response (raw): {response.text}")
            
            raise ClovaSpeechError(error_message)
        
        # Parse JSON response
        response_data: dict[str, Any] = response.json()
        logger.debug(f"Received response data: {response_data}")
        
        # Extract transcript from response
        # Note: Adjust the key path based on actual CLOVA Speech API response format
        # Common patterns: response["text"], response["result"]["text"], response["transcript"]
        transcript = _extract_transcript(response_data)
        
        if not transcript:
            logger.warning("Received empty transcript from CLOVA Speech")
            return ""
        
        logger.info(f"Successfully transcribed audio (length: {len(transcript)} chars)")
        return transcript
    
    except httpx.HTTPError as e:
        logger.error(f"HTTP error during CLOVA Speech request: {e}")
        raise ClovaSpeechError(f"Failed to connect to CLOVA Speech API: {e}")
    
    except Exception as e:
        logger.error(f"Unexpected error during transcription: {e}")
        raise ClovaSpeechError(f"Transcription failed: {e}")


def _extract_transcript(response_data: dict[str, Any]) -> str:
    """
    Extract transcript text from CLOVA Speech API response.

    This helper function handles the response structure parsing and provides
    a single point to update when the response format changes.

    For the current CLOVA Speech response (example):

        {
            "result": "COMPLETED",
            "message": "Succeeded",
            ...
            "segments": [
                {
                    "start": 5870,
                    "end": 8160,
                    "text": "서울 수영장입니다.",
                    "confidence": 0.9626975,
                    "diarization": {"label": "2"},
                    "speaker": {"label": "2", "name": "B", "edited": false},
                    "words": [...],
                    "textEdited": "서울 수영장입니다."
                },
                ...
            ],
            "text": "서울 수영장입니다. 입장료가 얼마예요? 5천 원이에요. 감사합니다.",
            ...
        }

    we build an LLM-friendly dialog string like:

        B: 서울 수영장입니다.
        A: 입장료가 얼마예요? 5천 원이에요. 감사합니다.

    Args:
        response_data: The JSON response from CLOVA Speech API

    Returns:
        str: The extracted transcript text, formatted for LLM consumption.
    """

    # 1) Preferred: use segments with speaker info and (edited) text
    segments = response_data.get("segments")
    if isinstance(segments, list) and segments:
        lines: list[str] = []

        for seg in segments:
            if not isinstance(seg, dict):
                continue

            # Prefer textEdited if present, fall back to text
            text = seg.get("textEdited") or seg.get("text") or ""
            if not isinstance(text, str) or not text.strip():
                continue
            text = text.strip()

            # Speaker info: try speaker.name -> speaker.label -> diarization.label
            speaker_name = None
            speaker_info = seg.get("speaker") or seg.get("diarization")

            if isinstance(speaker_info, dict):
                speaker_name = speaker_info.get("name") or speaker_info.get("label")

            if not isinstance(speaker_name, str) or not speaker_name.strip():
                # Generic fallback if no label/name available
                speaker_name = "Speaker"

            lines.append(f"{speaker_name}: {text}")

        if lines:
            # Dialog-style text is very LLM-friendly
            formatted_dialog = "\n".join(lines)
            logger.debug(f"Extracted dialog-style transcript from segments:\n{formatted_dialog}")
            return formatted_dialog

    # 2) Fallback: use top-level text if available
    top_level_text = response_data.get("text")
    if isinstance(top_level_text, str) and top_level_text.strip():
        logger.debug("Using top-level 'text' field for transcript.")
        return top_level_text.strip()

    # 3) Additional generic fallbacks for other possible shapes
    #    - {"result": {"text": "..."}}
    result_obj = response_data.get("result")
    if isinstance(result_obj, dict):
        nested_text = result_obj.get("text")
        if isinstance(nested_text, str) and nested_text.strip():
            logger.debug("Using nested 'result.text' field for transcript.")
            return nested_text.strip()

    #    - {"segments": [{"text": "..."}, ...]} without speaker info
    if isinstance(segments, list) and segments:
        texts = []
        for seg in segments:
            if isinstance(seg, dict):
                t = seg.get("textEdited") or seg.get("text")
                if isinstance(t, str) and t.strip():
                    texts.append(t.strip())
        if texts:
            concatenated = " ".join(texts)
            logger.debug("Using concatenated 'segments[*].text' for transcript.")
            return concatenated

    # 4) If no known structure matches, log and return empty string
    logger.warning(
        "Unknown CLOVA Speech response structure, returning empty transcript. "
        f"Top-level keys: {list(response_data.keys())}"
    )
    return ""