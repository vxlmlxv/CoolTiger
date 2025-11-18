"""
Firestore database client for the FastAPI backend application.

This module initializes Firebase Admin SDK and provides helper functions
for managing senior call records and conversation turns in Firestore.
"""

import firebase_admin
from firebase_admin import credentials, firestore
from google.cloud.firestore_v1 import SERVER_TIMESTAMP

from config import settings


# Initialize Firebase app (only once)
_app_initialized = False

if not _app_initialized:
    cred = credentials.Certificate(settings.google_application_credentials)
    firebase_admin.initialize_app(cred, {
        'projectId': settings.google_project_id,
    })
    _app_initialized = True

# Global Firestore client instance
db: firestore.Client = firestore.client()


def create_call_doc(senior_id: str) -> str:
    """
    Create a new call document for a senior.
    
    Creates a document under the path seniors/{senior_id}/calls with initial
    fields including the senior ID and start timestamp.
    
    Args:
        senior_id: The unique identifier for the senior
        
    Returns:
        str: The newly created call document ID (callId)
        
    Example:
        >>> call_id = create_call_doc("senior_123")
        >>> print(f"Created call: {call_id}")
    """
    call_ref = db.collection('seniors').document(senior_id).collection('calls').document()
    
    call_ref.set({
        'seniorId': senior_id,
        'startedAt': SERVER_TIMESTAMP,
    })
    
    return call_ref.id


def append_turn(senior_id: str, call_id: str, speaker: str, text: str) -> None:
    """
    Append a conversation turn to a call.
    
    Adds a new turn document under seniors/{senior_id}/calls/{call_id}/turns
    with the speaker identifier, spoken text, and timestamp.
    
    Args:
        senior_id: The unique identifier for the senior
        call_id: The call document ID
        speaker: Identifier for who is speaking (e.g., "senior", "assistant")
        text: The text content of what was said
        
    Example:
        >>> append_turn("senior_123", "call_456", "senior", "Hello, how are you?")
        >>> append_turn("senior_123", "call_456", "assistant", "I'm doing well, thank you!")
    """
    turns_ref = (
        db.collection('seniors')
        .document(senior_id)
        .collection('calls')
        .document(call_id)
        .collection('turns')
    )
    
    turns_ref.add({
        'speaker': speaker,
        'text': text,
        'timestamp': SERVER_TIMESTAMP,
    })


def finalize_call(senior_id: str, call_id: str, summary: str, mood: str, risk_level: str) -> None:
    """
    Finalize a call with summary information.
    
    Updates the call document with end timestamp and analysis results including
    summary, mood assessment, and risk level evaluation.
    
    Args:
        senior_id: The unique identifier for the senior
        call_id: The call document ID
        summary: Summary of the conversation
        mood: Assessed mood of the senior (e.g., "happy", "sad", "neutral")
        risk_level: Risk assessment level (e.g., "low", "medium", "high")
        
    Example:
        >>> finalize_call(
        ...     "senior_123",
        ...     "call_456",
        ...     "Pleasant conversation about family",
        ...     "happy",
        ...     "low"
        ... )
    """
    call_ref = (
        db.collection('seniors')
        .document(senior_id)
        .collection('calls')
        .document(call_id)
    )
    
    call_ref.update({
        'endedAt': SERVER_TIMESTAMP,
        'summary': summary,
        'mood': mood,
        'riskLevel': risk_level,
    })


def get_all_turns(senior_id: str, call_id: str) -> list[dict]:
    """
    Retrieve all conversation turns for a call.
    
    Fetches all turn documents for a specific call, ordered by timestamp
    in ascending order (chronological).
    
    Args:
        senior_id: The unique identifier for the senior
        call_id: The call document ID
        
    Returns:
        list[dict]: List of turn dictionaries containing speaker, text, and timestamp.
                   Timestamps are converted to ISO format strings for JSON serialization.
        
    Example:
        >>> turns = get_all_turns("senior_123", "call_456")
        >>> for turn in turns:
        ...     print(f"{turn['speaker']}: {turn['text']}")
    """
    turns_ref = (
        db.collection('seniors')
        .document(senior_id)
        .collection('calls')
        .document(call_id)
        .collection('turns')
        .order_by('timestamp')
    )
    
    turns = []
    for doc in turns_ref.stream():
        turn_data = doc.to_dict()
        
        # Convert Firestore timestamp to ISO format string for JSON serialization
        if 'timestamp' in turn_data and turn_data['timestamp']:
            turn_data['timestamp'] = turn_data['timestamp'].isoformat()
        
        turns.append(turn_data)
    
    return turns
