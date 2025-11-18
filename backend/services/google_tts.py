"""
Google Cloud Text-to-Speech service wrapper.

This module provides functions to synthesize speech from text using
Google Cloud's Text-to-Speech API.
"""

import logging
from typing import Optional

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
    
    if not settings.google_tts_audio_encoding:
        logger.error("Google TTS audio encoding is not configured")
        raise ValueError("google_tts_audio_encoding is not configured in settings")
    
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
        )
        
        # Map audio encoding string to enum
        audio_encoding = _get_audio_encoding(settings.google_tts_audio_encoding)
        
        # Configure audio output
        audio_config = texttospeech.AudioConfig(
            audio_encoding=audio_encoding,
        )
        
        # Perform TTS request
        logger.debug("Calling Google TTS API")
        response = client.synthesize_speech(
            input=synthesis_input,
            voice=voice,
            audio_config=audio_config,
        )
        
        # Extract audio content from response
        audio_bytes = response.audio_content
        
        if not audio_bytes:
            logger.error("Received empty audio content from Google TTS")
            raise GoogleTTSError("Google TTS returned empty audio content")
        
        logger.info(f"Successfully synthesized speech (audio size: {len(audio_bytes)} bytes)")
        return audio_bytes
    
    except Exception as e:
        logger.error(f"Failed to synthesize speech: {e}")
        if isinstance(e, (GoogleTTSError, ValueError)):
            raise
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


def synthesize_speech_with_options(
    text: str,
    language_code: Optional[str] = None,
    voice_name: Optional[str] = None,
    audio_encoding: Optional[str] = None,
    speaking_rate: float = 1.0,
    pitch: float = 0.0,
) -> bytes:
    """
    Synthesize speech with custom options, overriding defaults from config.
    
    Provides more control over TTS parameters for specific use cases.
    
    Args:
        text: The text to convert to speech
        language_code: Optional language code override (e.g., "ko-KR", "en-US")
        voice_name: Optional voice name override (e.g., "ko-KR-Wavenet-A")
        audio_encoding: Optional audio encoding override (e.g., "MP3", "LINEAR16")
        speaking_rate: Speech speed multiplier (0.25 to 4.0, default 1.0)
        pitch: Voice pitch adjustment (-20.0 to 20.0, default 0.0)
        
    Returns:
        bytes: Raw audio data
        
    Raises:
        GoogleTTSError: If the TTS request fails
        ValueError: If parameters are invalid
        
    Example:
        >>> audio = synthesize_speech_with_options(
        ...     "Hello, how are you?",
        ...     language_code="en-US",
        ...     speaking_rate=0.9,
        ...     pitch=-2.0
        ... )
    """
    # Use provided values or fall back to config
    lang_code = language_code or settings.google_tts_language_code
    voice = voice_name or settings.google_tts_voice_name
    encoding = audio_encoding or settings.google_tts_audio_encoding
    
    if not lang_code or not voice or not encoding:
        raise ValueError("Missing required TTS configuration")
    
    logger.info(f"Synthesizing speech with custom options (rate: {speaking_rate}, pitch: {pitch})")
    
    try:
        client = texttospeech.TextToSpeechClient()
        
        synthesis_input = texttospeech.SynthesisInput(text=text)
        
        voice_params = texttospeech.VoiceSelectionParams(
            language_code=lang_code,
            name=voice,
        )
        
        audio_encoding_enum = _get_audio_encoding(encoding)
        
        audio_config = texttospeech.AudioConfig(
            audio_encoding=audio_encoding_enum,
            speaking_rate=speaking_rate,
            pitch=pitch,
        )
        
        response = client.synthesize_speech(
            input=synthesis_input,
            voice=voice_params,
            audio_config=audio_config,
        )
        
        audio_bytes = response.audio_content
        
        if not audio_bytes:
            raise GoogleTTSError("Google TTS returned empty audio content")
        
        logger.info(f"Successfully synthesized speech with custom options (size: {len(audio_bytes)} bytes)")
        return audio_bytes
    
    except Exception as e:
        logger.error(f"Failed to synthesize speech with custom options: {e}")
        if isinstance(e, (GoogleTTSError, ValueError)):
            raise
        raise GoogleTTSError(f"Google TTS synthesis failed: {e}")
