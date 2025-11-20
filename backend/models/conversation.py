"""
Conversation models for AI call feature.

This module defines Pydantic models for managing AI-powered conversation
sessions with seniors, including starting calls, handling replies, and
ending conversations with analysis.
"""

from pydantic import BaseModel


class ConversationStartRequest(BaseModel):
    """
    Request model for starting a new conversation with a senior.
    
    Attributes:
        senior_id: Unique identifier for the senior user
        
    Example:
        >>> request = ConversationStartRequest(senior_id="senior_123")
    """
    senior_id: str


class ConversationStartResponse(BaseModel):
    """
    Response model for conversation start endpoint.
    
    Contains the initial AI greeting and call session information.
    
    Attributes:
        success: Whether the conversation was successfully started
        call_id: Unique identifier for this call session
        ai_text: The AI's initial greeting text
        tts_url: Optional URL to the text-to-speech audio file
        message: Optional message with additional context or error details
        
    Example:
        >>> response = ConversationStartResponse(
        ...     success=True,
        ...     call_id="call_456",
        ...     ai_text="Hello! How are you feeling today?",
        ...     tts_url="https://storage.example.com/audio.mp3"
        ... )
    """
    success: bool
    call_id: str
    ai_text: str
    tts_url: str | None = None
    message: str | None = None


class ConversationReplyResponse(BaseModel):
    """
    Response model for AI replies during an ongoing conversation.
    
    Contains the AI's response to the senior's input.
    
    Attributes:
        success: Whether the reply was successfully generated
        ai_text: The AI's response text
        senior_text: The transcribed text from the senior's audio input
        tts_url: Optional URL to the text-to-speech audio file
        message: Optional message with additional context or error details
        
    Example:
        >>> response = ConversationReplyResponse(
        ...     success=True,
        ...     ai_text="That sounds wonderful! Tell me more.",
        ...     senior_text="I went for a walk today.",
        ...     tts_url="https://storage.example.com/reply_audio.mp3"
        ... )
    """
    success: bool
    ai_text: str
    senior_text: str
    tts_url: str | None = None
    message: str | None = None


class ConversationEndRequest(BaseModel):
    """
    Request model for ending a conversation session.
    
    Attributes:
        senior_id: Unique identifier for the senior user
        call_id: Unique identifier for the call session to end
        
    Example:
        >>> request = ConversationEndRequest(
        ...     senior_id="senior_123",
        ...     call_id="call_456"
        ... )
    """
    senior_id: str
    call_id: str


class ConversationEndResponse(BaseModel):
    """
    Response model for conversation end endpoint.
    
    Contains analysis results from the conversation including summary,
    mood assessment, and risk evaluation.
    
    Attributes:
        success: Whether the conversation was successfully ended and analyzed
        summary: Optional summary of the conversation
        mood: Optional assessed mood of the senior (e.g., "happy", "sad", "neutral")
        risk_level: Optional risk assessment (e.g., "low", "medium", "high")
        message: Optional message with additional context or error details
        
    Example:
        >>> response = ConversationEndResponse(
        ...     success=True,
        ...     summary="Pleasant conversation about family activities",
        ...     mood="happy",
        ...     risk_level="low",
        ...     message="Call ended successfully"
        ... )
    """
    success: bool
    summary: str | None = None
    mood: str | None = None
    risk_level: str | None = None
    message: str | None = None
