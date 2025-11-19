"""
Naver CLOVA Studio LLM service wrapper.

This module provides functions to interact with Naver's CLOVA Studio API
for generating conversational replies and analyzing conversation transcripts.
"""

import json
import logging
from typing import Any

import httpx

from config import settings

# Configure logger
logger = logging.getLogger(__name__)


class ClovaStudioError(Exception):
    """Custom exception for CLOVA Studio API errors."""
    pass


def generate_reply(transcript_history: list[dict], senior_profile: dict) -> str:
    """
    Generate a conversational reply using CLOVA Studio LLM.

    Creates a contextual prompt from the conversation history and senior profile,
    then calls CLOVA Studio to generate a warm, friendly response in Korean.

    Args:
        transcript_history: List of conversation turns, each dict containing:
                           {"speaker": "senior" | "ai", "text": "..."}
        senior_profile: Dictionary with senior information:
                       {"name": str, "age": int, "preferences": str, ...}

    Returns:
        str: The generated AI response text (1-2 sentences in Korean)

    Raises:
        ClovaStudioError: If the API request fails
        ValueError: If required configuration is missing
    """
    # 1) Check env config
    _validate_config()

    # 2) Build the user-facing prompt text from history + profile
    prompt = _build_conversation_prompt(transcript_history, senior_profile)

    logger.info("Generating conversational reply with CLOVA Studio")
    logger.debug(f"Prompt length: {len(prompt)} chars")

    # 3) Build CLOVA Studio v3/chat-completions payload
    #    - system: role / behavior
    #    - user:   actual prompt text
    payload: dict[str, Any] = {
        "messages": [
            {
                "role": "system",
                "content": [
                    {
                        "type": "text",
                        "text": (
                            "You are a warm, caring Korean-speaking AI companion "
                            "talking to an elderly person. "
                            "Always respond in polite, natural Korean, "
                            "in 1-2 sentences, showing empathy and interest in "
                            "their daily life and well-being."
                        ),
                    }
                ],
            },
            {
                "role": "user",
                "content": [
                    {
                        "type": "text",
                        "text": prompt,
                    }
                ],
            },
        ],

        "includeAiFilters": True,
    }

    try:
        # 4) Call CLOVA Studio
        response_data = _call_clova_studio(payload)

        # 5) Extract the assistant's text from the response
        generated_text = _extract_generated_text(response_data)

        if not generated_text:
            logger.warning("Received empty response from CLOVA Studio")
            return "죄송합니다, 다시 말씀해 주시겠어요?"  # Fallback reply

        logger.info(
            f"Successfully generated reply (length: {len(generated_text)} chars)"
        )
        return generated_text.strip()

    except Exception as e:
        logger.error(f"Failed to generate reply: {e}")
        raise

def analyze_conversation(full_transcript: str, senior_profile: dict) -> dict:
    """
    Analyze a complete conversation transcript using CLOVA Studio LLM.

    Sends the full conversation transcript to CLOVA Studio with instructions
    to analyze the conversation and return structured analysis including summary,
    mood assessment, and risk level evaluation.

    Args:
        full_transcript: Complete conversation transcript as a single string
        senior_profile: Dictionary with senior information:
                       {"name": str, "age": int, "preferences": str, ...}

    Returns:
        dict: Analysis results with keys:
              - summary (str): Brief conversation summary
              - mood (str): Assessed mood (e.g., "happy", "sad", "neutral", "anxious")
              - risk_level (str): Risk assessment (e.g., "low", "medium", "high")

    Raises:
        ClovaStudioError: If the API request fails or JSON parsing fails
        ValueError: If required configuration is missing
    """
    # 1) Check env config
    _validate_config()

    # 2) Build analysis prompt (includes instructions + transcript)
    analysis_prompt = _build_analysis_prompt(full_transcript, senior_profile)

    logger.info("Analyzing conversation with CLOVA Studio")
    logger.debug(f"Transcript length: {len(full_transcript)} chars")

    # 3) Build CLOVA Studio v3/chat-completions payload
    payload: dict[str, Any] = {
        "messages": [
            {
                "role": "system",
                "content": [
                    {
                        "type": "text",
                        "text": (
                            "You are an expert mental health and wellness analyst. "
                            "You analyze conversations with elderly users and return "
                            "ONLY valid JSON with the keys summary, mood, risk_level in Korean."
                        ),
                    }
                ],
            },
            {
                "role": "user",
                "content": [
                    {
                        "type": "text",
                        "text": analysis_prompt,
                    }
                ],
            },
        ],
        "temperature": 0.3,  # lower temp = more stable JSON
        "includeAiFilters": True,
    }

    try:
        # 4) Call CLOVA Studio
        response_data = _call_clova_studio(payload)

        # 5) Get raw text (should be JSON or JSON + noise)
        generated_text = _extract_generated_text(response_data)
        if not generated_text:
            logger.error("Received empty analysis from CLOVA Studio")
            raise ClovaStudioError("Empty response from CLOVA Studio")

        # 6) Parse JSON from the text (robust to extra explanation)
        analysis = _parse_analysis_json(generated_text)

        logger.info(
            "Successfully analyzed conversation: "
            f"mood={analysis.get('mood')}, risk={analysis.get('risk_level')}"
        )
        return analysis

    except Exception as e:
        logger.error(f"Failed to analyze conversation: {e}")
        raise

def _validate_config() -> None:
    """Validate that required CLOVA Studio configuration is present."""
    if not settings.clova_studio_endpoint:
        raise ValueError("CLOVA Studio endpoint is not configured in settings")
    
    if not settings.clova_studio_api_key:
        raise ValueError("CLOVA Studio API key is not configured in settings")
    
    if not settings.clova_studio_api_secret:
        raise ValueError("CLOVA Studio API secret is not configured in settings")


def _call_clova_studio(payload: dict[str, Any]) -> dict[str, Any]:
    """
    Make HTTP request to CLOVA Studio API.

    Args:
        payload: Request payload dictionary

    Returns:
        dict: JSON response from CLOVA Studio

    Raises:
        ClovaStudioError: If the request fails
    """

    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {settings.clova_studio_api_key}",
    }

    url = settings.clova_studio_endpoint + "v3/chat-completions/HCX-DASH-002"

    try:
        logger.debug(f"Calling CLOVA Studio endpoint: {url}")

        with httpx.Client(timeout=60.0) as client:
            response = client.post(
                url,
                headers=headers,
                json=payload,
            )

        logger.info(f"CLOVA Studio API response status: {response.status_code}")

        # HTTP error handling
        if response.status_code != 200:
            error_message = f"CLOVA Studio API error: {response.status_code}"
            try:
                error_data = response.json()
                error_message += f" - {error_data}"
                logger.error(f"API error response: {error_data}")
            except Exception:
                error_message += f" - {response.text}"
                logger.error(f"API error response (raw): {response.text}")

            raise ClovaStudioError(error_message)

        return response.json()

    except httpx.HTTPError as e:
        logger.error(f"HTTP error during CLOVA Studio request: {e}")
        raise ClovaStudioError(f"Failed to connect to CLOVA Studio API: {e}")

def _build_conversation_prompt(transcript_history: list[dict], senior_profile: dict) -> str:
    """
    Build a prompt for conversational reply generation.
    
    Args:
        transcript_history: List of conversation turns
        senior_profile: Senior's profile information
        
    Returns:
        str: Formatted prompt for the LLM
    """
    # Format senior profile
    name = senior_profile.get("name", "어르신")
    age = senior_profile.get("age", "70")
    preferences = senior_profile.get("preferences", "")
    
    profile_text = f"대화 상대: {name}"
    if age:
        profile_text += f" ({age}세)"
    if preferences:
        profile_text += f"\n관심사: {preferences}"
    
    # Format conversation history
    history_text = "\n".join([
        f"{'AI' if turn['speaker'] == 'ai' else '어르신'}: {turn['text']}"
        for turn in transcript_history[-5:]  # Last 5 turns for context
    ])
    
    # Build complete prompt
    prompt = f"""{profile_text}

최근 대화:
{history_text}

위 대화를 바탕으로, 따뜻하고 친근한 톤으로 1-2문장의 짧은 한국어 응답을 생성해주세요. 
어르신의 말씀에 공감하고 자연스럽게 대화를 이어가세요."""
    
    return prompt


def _build_analysis_prompt(full_transcript: str, senior_profile: dict) -> str:
    """
    Build a prompt for conversation analysis.
    
    Args:
        full_transcript: Complete conversation transcript
        senior_profile: Senior's profile information
        
    Returns:
        str: Formatted prompt for analysis
    """
    name = senior_profile.get("name", "어르신")
    age = senior_profile.get("age", "")
    
    profile_text = f"{name}"
    if age:
        profile_text += f" ({age}세)"
    
    prompt = f"""다음은 {profile_text}와의 대화 내용입니다:

{full_transcript}

위 대화를 분석하여 다음 정보를 JSON 형식으로 제공해주세요:

1. summary: 대화 내용을 2-3문장으로 요약
2. mood: 어르신의 전반적인 기분 평가 (happy, sad, neutral, anxious, depressed 중 선택)
3. risk_level: 건강/안전 위험도 평가 (low, medium, high 중 선택)

응답은 반드시 다음과 같은 유효한 JSON 형식이어야 합니다:
{{
  "summary": "대화 요약 내용",
  "mood": "기분 상태",
  "risk_level": "위험도"
}}

JSON만 출력하고 다른 설명은 포함하지 마세요."""
    
    return prompt


def _extract_generated_text(response_data: dict[str, Any]) -> str:
    """
    Extract generated text from CLOVA Studio response.

    Expected shape (from v3/chat-completions):

    {
        "status": { ... },
        "result": {
            "message": {
                "role": "assistant",
                "content": "..."
            },
            ...
        }
    }

    Args:
        response_data: JSON response from CLOVA Studio

    Returns:
        str: Extracted assistant message text (or "" if missing)
    """
    # Safest path: result.message.content
    result = response_data.get("result")
    if isinstance(result, dict):
        message = result.get("message")
        if isinstance(message, dict):
            content = message.get("content")
            if isinstance(content, str):
                return content

    # Extra fallback: sometimes someone might pass result directly
    if "message" in response_data and isinstance(response_data["message"], dict):
        content = response_data["message"].get("content")
        if isinstance(content, str):
            return content

    logger.warning(f"Unknown response structure. Keys: {list(response_data.keys())}")
    return ""

def _parse_analysis_json(text: str) -> dict:
    """
    Parse analysis JSON from LLM response text.
    
    Handles cases where the model includes extra text around the JSON.
    
    Args:
        text: Response text that should contain JSON
        
    Returns:
        dict: Parsed analysis with summary, mood, and risk_level
        
    Raises:
        ClovaStudioError: If JSON parsing fails
    """
    try:
        # Try direct JSON parse first
        return json.loads(text)
    except json.JSONDecodeError:
        # Try to extract JSON from markdown code blocks or surrounding text
        import re
        
        # Look for JSON within code blocks
        json_match = re.search(r'```(?:json)?\s*(\{.*?\})\s*```', text, re.DOTALL)
        if json_match:
            try:
                return json.loads(json_match.group(1))
            except json.JSONDecodeError:
                pass
        
        # Look for JSON object in the text
        json_match = re.search(r'\{[^{}]*"summary"[^{}]*"mood"[^{}]*"risk_level"[^{}]*\}', text, re.DOTALL)
        if json_match:
            try:
                return json.loads(json_match.group(0))
            except json.JSONDecodeError:
                pass
        
        logger.error(f"Failed to parse analysis JSON from text: {text[:200]}")
        raise ClovaStudioError("Failed to parse analysis JSON from CLOVA Studio response")
