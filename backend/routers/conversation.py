"""
Conversation router for AI senior call feature.

This module provides endpoints for managing AI-powered conversation sessions
with seniors, including starting calls, handling voice replies, and ending
calls with analysis.
"""

import logging

from fastapi import APIRouter, UploadFile, File, Form, HTTPException, status

from models.conversation import (
    ConversationStartRequest,
    ConversationStartResponse,
    ConversationReplyResponse,
    ConversationEndRequest,
    ConversationEndResponse,
)
from db.firestore_client import create_call_doc, append_turn, get_all_turns, finalize_call
from services.clova_speech import transcribe_audio
from services.clova_studio import generate_reply, analyze_conversation
from services.google_tts import synthesize_speech

# Configure logger
logger = logging.getLogger(__name__)

# Create conversation router
router = APIRouter(prefix="/conversation", tags=["conversation"])

# Maximum number of recent turns to keep in context (to prevent context explosion)
MAX_CONTEXT_TURNS = 10


@router.post("/start", response_model=ConversationStartResponse)
async def start_conversation(request: ConversationStartRequest):
    """
    Start a new conversation session with a senior.
    
    Creates a new call document in Firestore, generates an initial AI greeting,
    synthesizes speech audio, and returns the call ID and greeting.
    
    Args:
        request: Contains senior_id
        
    Returns:
        ConversationStartResponse with call_id, ai_text, and tts_url
        
    Raises:
        HTTPException: If call creation or AI generation fails
        
    Example:
        POST /conversation/start
        {"senior_id": "senior_123"}
    """
    try:
        logger.info(f"Starting conversation for senior: {request.senior_id}")
        
        # Create call document in Firestore
        call_id = create_call_doc(request.senior_id)
        logger.info(f"Created call document: {call_id}")
        
        # TODO: Replace with actual senior profile from database
        # For MVP, using dummy profile
        senior_profile = {
            "name": "홍길동",
            "age": 70,
            "preferences": "가족, 건강"
        }
        
        # Generate initial AI greeting with empty conversation history
        transcript_history = []
        ai_text = generate_reply(transcript_history, senior_profile)
        logger.info(f"Generated greeting: {ai_text[:50]}...")
        
        # Save AI greeting turn to Firestore
        append_turn(request.senior_id, call_id, "ai", ai_text)
        logger.info("Saved AI greeting turn to Firestore")
        
        # Synthesize speech audio
        audio_bytes = synthesize_speech(ai_text)
        logger.info(f"Synthesized speech audio: {len(audio_bytes)} bytes")
        
        # TODO: Upload audio_bytes to cloud storage (GCS, S3) and get public URL
        # For MVP, we'll set tts_url to None or placeholder
        # In production, you would:
        # 1. Upload audio_bytes to Google Cloud Storage
        # 2. Generate a signed URL or make it publicly accessible
        # 3. Return that URL in tts_url
        tts_url = None  # Placeholder - implement cloud storage upload
        
        return ConversationStartResponse(
            success=True,
            call_id=call_id,
            ai_text=ai_text,
            tts_url=tts_url,
            message="Conversation started successfully"
        )
    
    except Exception as e:
        logger.error(f"Failed to start conversation: {e}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to start conversation: {str(e)}"
        )


@router.post("/reply", response_model=ConversationReplyResponse)
async def reply_to_conversation(
    senior_id: str = Form(...),
    call_id: str = Form(...),
    audio: UploadFile = File(...),
):
    """
    Process a senior's voice reply and generate AI response.
    
    Accepts audio from the senior, transcribes it using CLOVA Speech,
    generates an AI response using conversation history, synthesizes
    the response to audio, and saves all turns to Firestore.
    
    Args:
        senior_id: Unique identifier for the senior
        call_id: The call session ID
        audio: Audio file with the senior's voice input
        
    Returns:
        ConversationReplyResponse with ai_text and tts_url
        
    Raises:
        HTTPException: If transcription, generation, or database operations fail
        
    Example:
        POST /conversation/reply
        Content-Type: multipart/form-data
        senior_id=senior_123&call_id=call_456&audio=<audio_file>
    """
    try:
        logger.info(f"Processing reply for call: {call_id}, senior: {senior_id}")
        
        # Read audio bytes from uploaded file
        audio_bytes = await audio.read()
        logger.info(f"Received audio file: {len(audio_bytes)} bytes, content_type: {audio.content_type}")
        
        # Determine MIME type
        mime_type = audio.content_type or "audio/wav"
        
        # Transcribe audio to text using CLOVA Speech
        senior_text = transcribe_audio(audio_bytes, mime_type)
        logger.info(f"Transcribed senior speech: {senior_text[:100]}...")
        
        if not senior_text.strip():
            logger.warning("Received empty transcript from CLOVA Speech")
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Could not transcribe audio. Please try again."
            )
        
        # Save senior's turn to Firestore
        append_turn(senior_id, call_id, "senior", senior_text)
        logger.info("Saved senior turn to Firestore")
        
        # Fetch recent conversation turns
        all_turns = get_all_turns(senior_id, call_id)
        logger.info(f"Retrieved {len(all_turns)} total turns from Firestore")
        
        # Limit context to recent turns to prevent context explosion
        recent_turns = all_turns[-MAX_CONTEXT_TURNS:] if len(all_turns) > MAX_CONTEXT_TURNS else all_turns
        
        # Format turns for generate_reply function
        transcript_history = [
            {"speaker": turn["speaker"], "text": turn["text"]}
            for turn in recent_turns
        ]
        
        # TODO: Fetch actual senior profile from database
        # For MVP, using dummy profile
        senior_profile = {
            "name": "어르신",
            "age": 75,
            "preferences": "가족, 건강"
        }
        
        # Generate AI response
        ai_text = generate_reply(transcript_history, senior_profile)
        logger.info(f"Generated AI reply: {ai_text[:50]}...")
        
        # Save AI turn to Firestore
        append_turn(senior_id, call_id, "ai", ai_text)
        logger.info("Saved AI reply turn to Firestore")
        
        # Synthesize speech audio
        audio_bytes = synthesize_speech(ai_text)
        logger.info(f"Synthesized speech audio: {len(audio_bytes)} bytes")
        
        # TODO: Upload audio_bytes to cloud storage and get public URL
        # For MVP, setting tts_url to None
        # In production:
        # 1. Upload to cloud storage with unique filename (e.g., {call_id}_{timestamp}.mp3)
        # 2. Return signed or public URL
        # 3. Consider implementing audio streaming for better UX
        tts_url = None  # Placeholder - implement cloud storage upload
        
        return ConversationReplyResponse(
            success=True,
            ai_text=ai_text,
            tts_url=tts_url,
            message="Reply processed successfully"
        )
    
    except HTTPException:
        # Re-raise HTTP exceptions as-is
        raise
    
    except Exception as e:
        logger.error(f"Failed to process reply: {e}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to process reply: {str(e)}"
        )


@router.post("/end", response_model=ConversationEndResponse)
async def end_conversation(request: ConversationEndRequest):
    """
    End a conversation session and analyze the call.
    
    Retrieves the complete conversation transcript, analyzes it using
    CLOVA Studio to extract summary, mood, and risk level, then finalizes
    the call document in Firestore with the analysis results.
    
    Args:
        request: Contains senior_id and call_id
        
    Returns:
        ConversationEndResponse with analysis results (summary, mood, risk_level)
        
    Raises:
        HTTPException: If analysis or database operations fail
        
    Example:
        POST /conversation/end
        {"senior_id": "senior_123", "call_id": "call_456"}
    """
    try:
        logger.info(f"Ending conversation for call: {request.call_id}, senior: {request.senior_id}")
        
        # Fetch all turns for the call
        all_turns = get_all_turns(request.senior_id, request.call_id)
        logger.info(f"Retrieved {len(all_turns)} turns for analysis")
        
        if not all_turns:
            logger.warning("No turns found for this call")
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="No conversation turns found for this call"
            )
        
        # Build full transcript string
        full_transcript = "\n".join([
            f"{'AI' if turn['speaker'] == 'ai' else '어르신'}: {turn['text']}"
            for turn in all_turns
        ])
        logger.info(f"Built full transcript: {len(full_transcript)} characters")
        
        # TODO: Fetch actual senior profile from database
        # For MVP, using dummy profile
        senior_profile = {
            "name": "어르신",
            "age": 75,
            "preferences": "가족, 건강"
        }
        
        # Analyze conversation using CLOVA Studio
        analysis = analyze_conversation(full_transcript, senior_profile)
        logger.info(f"Analysis complete: mood={analysis.get('mood')}, risk={analysis.get('risk_level')}")
        
        # Extract analysis fields with fallbacks
        summary = analysis.get("summary", "대화 요약을 생성할 수 없습니다.")
        mood = analysis.get("mood", "neutral")
        risk_level = analysis.get("risk_level", "low")
        
        # Finalize call document in Firestore
        finalize_call(
            request.senior_id,
            request.call_id,
            summary,
            mood,
            risk_level
        )
        logger.info("Finalized call document in Firestore")
        
        return ConversationEndResponse(
            success=True,
            summary=summary,
            mood=mood,
            risk_level=risk_level,
            message="Conversation ended and analyzed successfully"
        )
    
    except HTTPException:
        # Re-raise HTTP exceptions as-is
        raise
    
    except Exception as e:
        logger.error(f"Failed to end conversation: {e}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to end conversation: {str(e)}"
        )
