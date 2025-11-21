"""
Google Cloud Text-to-Speech service wrapper.

This module provides functions to synthesize speech from text using
Google Cloud's Text-to-Speech API.
"""

import logging
from typing import Optional

import os
from urllib import response
from google.cloud import texttospeech

from config import settings

# Configure logger
logger = logging.getLogger(__name__)


class GoogleTTSError(Exception):
    """Custom exception for Google TTS errors."""
    pass


def synthesize_speech(text: str) -> bytes:
    """
    Synthesize speech from text using Google Cloud Text-to-Speech.
    
    Converts the input text to speech audio using the configured voice settings.
    The function uses the language code, voice name, and audio encoding specified
    in the application configuration.
    
    Args:
        text: The text to convert to speech (supports SSML markup)
        
    Returns:
        bytes: Raw audio data in the configured encoding format
        
    Raises:
        GoogleTTSError: If the TTS request fails
        ValueError: If required configuration is missing
        
    Example:
        >>> audio_bytes = synthesize_speech("안녕하세요, 오늘 기분이 어떠세요?")
        >>> with open("output.mp3", "wb") as f:
        ...     f.write(audio_bytes)
        
    Note:
        Requires GOOGLE_APPLICATION_CREDENTIALS environment variable to be set
        pointing to a valid service account key file.
    """
    # Validate required configuration
    if not settings.google_tts_language_code:
        logger.error("Google TTS language code is not configured")
        raise ValueError("google_tts_language_code is not configured in settings")
    
    if not settings.google_tts_voice_name:
        logger.error("Google TTS voice name is not configured")
        raise ValueError("google_tts_voice_name is not configured in settings")
    
    logger.info(f"Synthesizing speech with Google TTS (length: {len(text)} chars)")
    logger.debug(f"Voice: {settings.google_tts_voice_name}, Language: {settings.google_tts_language_code}")
    
    try:
        # Create TTS client
        client = texttospeech.TextToSpeechClient()
        
        # Build synthesis input
        synthesis_input = texttospeech.SynthesisInput(text=text)
        
        # Configure voice parameters
        voice = texttospeech.VoiceSelectionParams(
            language_code=settings.google_tts_language_code,
            name=settings.google_tts_voice_name,
            model_name="gemini-2.5-pro-tts"
        )
        

        audio_config = texttospeech.AudioConfig(
        audio_encoding=texttospeech.AudioEncoding.MP3
    )
        
        # Perform TTS request
        logger.debug("Calling Google TTS API")
        response = client.synthesize_speech(
            input=synthesis_input,
            voice=voice,
            audio_config=audio_config
        )
        
        # Extract audio content from response
        audio_bytes = response.audio_content
        

        if not response.audio_content:
            logger.error(f"Google TTS API returned empty content. Text input was: '{text}'")
            raise GoogleTTSError("Google TTS returned empty audio content")
            
        logger.info(f"Successfully synthesized speech (audio size: {len(response.audio_content)} bytes)")
        return response.audio_content
    
    except Exception as e:
        logger.error(f"Failed to synthesize speech: {e}")
        raise GoogleTTSError(f"Google TTS synthesis failed: {e}")
    
    


def _get_audio_encoding(encoding_str: str) -> texttospeech.AudioEncoding:
    """
    Convert audio encoding string to Google TTS AudioEncoding enum.
    
    Args:
        encoding_str: Audio encoding as string (e.g., "MP3", "LINEAR16", "OGG_OPUS")
        
    Returns:
        texttospeech.AudioEncoding: Corresponding enum value
        
    Raises:
        ValueError: If the encoding string is not recognized
    """
    # Normalize the input string
    encoding_upper = encoding_str.upper().strip()
    
    # Map common encoding strings to enum values
    encoding_map = {
        "MP3": texttospeech.AudioEncoding.MP3,
        "LINEAR16": texttospeech.AudioEncoding.LINEAR16,
        "OGG_OPUS": texttospeech.AudioEncoding.OGG_OPUS,
        "MULAW": texttospeech.AudioEncoding.MULAW,
        "ALAW": texttospeech.AudioEncoding.ALAW,
    }
    
    if encoding_upper in encoding_map:
        return encoding_map[encoding_upper]
    
    # Try to get the enum by name directly
    try:
        return texttospeech.AudioEncoding[encoding_upper]
    except KeyError:
        logger.error(f"Unknown audio encoding: {encoding_str}")
        raise ValueError(
            f"Unknown audio encoding: {encoding_str}. "
            f"Supported values: {', '.join(encoding_map.keys())}"
        )
