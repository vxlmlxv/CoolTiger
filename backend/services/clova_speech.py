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
        "Content-Type": 'application/json;UTF-8',
    }
    
    body = {
        "url": audio_url,
        "language": "ko-KR",
    }

    try:
        # Send POST request to CLOVA Speech endpoint
        logger.debug(f"Sending request to {settings.clova_speech_endpoint}")
        
        with httpx.Client(timeout=30.0) as client:
            response = client.post(
                settings.clova_speech_endpoint + "/recognizer/url",
                headers=headers,
                content=audio_bytes,
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
    
    Args:
        response_data: The JSON response from CLOVA Speech API
        
    Returns:
        str: The extracted transcript text
        
    Note:
        Update this function based on the actual CLOVA Speech API response format.
        Common response structures:
        - {"text": "transcript here"}
        - {"result": {"text": "transcript here"}}
        - {"segments": [{"text": "part1"}, {"text": "part2"}]}
    """
    # TODO: Update based on actual CLOVA Speech response structure
    # Example implementations:
    
    # Option 1: Direct text field
    if "text" in response_data:
        return response_data["text"]
    
    # Option 2: Nested result
    if "result" in response_data and "text" in response_data["result"]:
        return response_data["result"]["text"]
    
    # Option 3: Segments that need concatenation
    if "segments" in response_data:
        segments = response_data["segments"]
        if isinstance(segments, list):
            texts = [seg.get("text", "") for seg in segments]
            return " ".join(texts)
    
    # If no known structure matches, log the structure for debugging
    logger.warning(f"Unknown response structure, returning empty string. Response keys: {response_data.keys()}")
    return ""
