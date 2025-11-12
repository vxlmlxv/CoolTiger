from __future__ import annotations

import io
import os
from datetime import datetime, timedelta, timezone
from typing import Any
from uuid import uuid4

from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile, status
from fastapi.responses import JSONResponse, StreamingResponse
from google.cloud import firestore, storage

from ..schemas import ConversationLog
from ..services import (
    ClovaSpeechDep,
    ClovaStudioDep,
    FirestoreDep,
    GoogleTTSDep,
    GoogleTTSService,
)

router = APIRouter()


@router.get("/conversation", response_model=list[ConversationLog])
async def list_conversations(senior_id: str, db: FirestoreDep = Depends()) -> list[ConversationLog]:
    docs = (
        db.collection("conversation_logs")
        .where("seniorId", "==", senior_id)
        .order_by("timestamp", direction=firestore.Query.DESCENDING)
        .limit(25)
        .stream()
    )
    results: list[ConversationLog] = []
    for doc in docs:
        payload = doc.to_dict()
        payload["id"] = doc.id
        results.append(ConversationLog.model_validate(payload))
    return results


@router.post("/conversation")
async def handle_conversation(
    senior_id: str = Form(..., alias="seniorId"),
    guardian_id: str = Form(..., alias="guardianId"),
    audio_file: UploadFile = File(...),
    db: FirestoreDep = Depends(),
    clova_speech: ClovaSpeechDep = Depends(),
    clova_studio: ClovaStudioDep = Depends(),
    google_tts: GoogleTTSDep = Depends(),
):
    bucket_name = _require_env("GCS_AUDIO_BUCKET")
    audio_bytes = await audio_file.read()
    if not audio_bytes:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Audio file is empty")

    storage_client = _get_storage_client()
    blob_prefix = f"conversations/{senior_id}"
    user_blob = _upload_bytes(
        storage_client=storage_client,
        bucket_name=bucket_name,
        payload=audio_bytes,
        destination=f"{blob_prefix}/raw/{uuid4().hex}-{audio_file.filename or 'clip.wav'}",
        content_type=audio_file.content_type or "audio/wav",
    )
    audio_signed_url = _signed_url(user_blob)

    stt_result = await clova_speech.transcribe(audio_signed_url)
    transcript = (stt_result or {}).get("text")
    confidence = (stt_result or {}).get("confidence")
    if not transcript:
        raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY, detail="Unable to transcribe audio")

    senior_profile = _fetch_senior_profile(db, senior_id)
    conversation_context = _build_conversation_context(db, senior_id)

    llm_payload = await clova_studio.generate_reply(
        transcript,
        {
            "personalHistory": senior_profile.get("personalHistory", {}),
            "conversationContext": conversation_context,
            "transcriptConfidence": confidence,
        },
    )
    reply_text = (llm_payload or {}).get("text")
    if not reply_text:
        raise HTTPException(status_code=status.HTTP_502_BAD_GATEWAY, detail="LLM returned no content")

    training_payload = (llm_payload or {}).get("training")
    timestamp = datetime.now(timezone.utc)

    # Persist user turn immediately
    _persist_conversation_log(
        db=db,
        senior_id=senior_id,
        guardian_id=guardian_id,
        speaker="user",
        transcript=transcript,
        audio_url=_gs_uri(user_blob),
        timestamp=timestamp,
    )

    if training_payload:
        response, training_blob = _prepare_training_response(
            training_payload,
            google_tts,
            storage_client,
            bucket_name,
            blob_prefix,
        )
        _persist_conversation_log(
            db=db,
            senior_id=senior_id,
            guardian_id=guardian_id,
            speaker="ai",
            transcript=reply_text,
            audio_url=_gs_uri(training_blob),
            timestamp=timestamp,
        )
        return JSONResponse(content=response)

    reply_audio_bytes = google_tts.synthesize(reply_text)
    reply_blob = _upload_bytes(
        storage_client=storage_client,
        bucket_name=bucket_name,
        payload=reply_audio_bytes,
        destination=f"{blob_prefix}/responses/{uuid4().hex}.mp3",
        content_type="audio/mpeg",
    )
    _persist_conversation_log(
        db=db,
        senior_id=senior_id,
        guardian_id=guardian_id,
        speaker="ai",
        transcript=reply_text,
        audio_url=_gs_uri(reply_blob),
        timestamp=timestamp,
    )
    return StreamingResponse(
        content=io.BytesIO(reply_audio_bytes),
        media_type="audio/mpeg",
        headers={"X-Audio-Url": _signed_url(reply_blob)},
    )


def _require_env(name: str) -> str:
    value = os.getenv(name)
    if not value:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Missing required environment variable: {name}",
        )
    return value


def _get_storage_client() -> storage.Client:
    return storage.Client()


def _upload_bytes(
    *,
    storage_client: storage.Client,
    bucket_name: str,
    payload: bytes,
    destination: str,
    content_type: str,
) -> storage.Blob:
    bucket = storage_client.bucket(bucket_name)
    blob = bucket.blob(destination)
    blob.upload_from_string(payload, content_type=content_type)
    return blob


def _signed_url(blob: storage.Blob, ttl_seconds: int = 3600) -> str:
    return blob.generate_signed_url(expiration=timedelta(seconds=ttl_seconds), method="GET")


def _gs_uri(blob: storage.Blob) -> str:
    return f"gs://{blob.bucket.name}/{blob.name}"


def _fetch_senior_profile(db: FirestoreDep, senior_id: str) -> dict[str, Any]:
    doc = db.collection("seniors").document(senior_id).get()
    if not doc.exists:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Senior profile not found")
    return doc.to_dict() or {}


def _build_conversation_context(db: FirestoreDep, senior_id: str) -> list[dict[str, Any]]:
    docs = (
        db.collection("conversation_logs")
        .where("seniorId", "==", senior_id)
        .order_by("timestamp", direction=firestore.Query.DESCENDING)
        .limit(5)
        .stream()
    )
    context: list[dict[str, Any]] = []
    for doc in docs:
        data = doc.to_dict()
        context.append({"speaker": data.get("speaker"), "transcript": data.get("transcript")})
    context.reverse()
    return context


def _persist_conversation_log(
    *,
    db: FirestoreDep,
    senior_id: str,
    guardian_id: str,
    speaker: str,
    transcript: str,
    audio_url: str | None,
    timestamp: datetime,
) -> None:
    payload = {
        "seniorId": senior_id,
        "guardianId": guardian_id,
        "timestamp": timestamp,
        "speaker": speaker,
        "transcript": transcript,
        "audioUrl": audio_url,
        "analysisStatus": "pending",
    }
    db.collection("conversation_logs").add(payload)


def _prepare_training_response(
    training_payload: dict[str, Any],
    google_tts: GoogleTTSService,
    storage_client: storage.Client,
    bucket_name: str,
    blob_prefix: str,
) -> tuple[dict[str, Any], storage.Blob]:
    tts_prompt = training_payload.get("tts_prompt") or "Let's try a quick brain exercise!"
    tts_audio = google_tts.synthesize(tts_prompt)
    blob = _upload_bytes(
        storage_client=storage_client,
        bucket_name=bucket_name,
        payload=tts_audio,
        destination=f"{blob_prefix}/training/{uuid4().hex}.mp3",
        content_type="audio/mpeg",
    )
    response = {
        "type": training_payload.get("type", "training_module"),
        "tts_audio_url": _signed_url(blob),
        "tts_prompt": tts_prompt,
        "module_type": training_payload.get("module_type", "card_match"),
        "module_data": training_payload.get("module_data", {}),
        "module_id": training_payload.get("module_id"),
    }
    return response, blob
