"""
Quiz router for cognitive assessment feature.

This module provides endpoints for retrieving quiz questions and submitting
quiz answers for senior cognitive assessments.
"""

import logging

from fastapi import APIRouter, HTTPException, Query, status
from google.cloud.firestore_v1 import SERVER_TIMESTAMP

from models.quiz import (
    QuizListResponse,
    QuizSubmitRequest,
    QuizSubmitResponse,
    QuizSession,
    QuizQuestion,
    QuizQuestionOption,
)
from db.firestore_client import db

# Configure logger
logger = logging.getLogger(__name__)

# Create quiz router
router = APIRouter(prefix="/quiz", tags=["quiz"])


@router.get("/list", response_model=QuizListResponse)
async def get_quiz_list(senior_id: str = Query(..., description="Senior user ID")):
    """
    Retrieve a quiz session for a senior.
    
    Returns a quiz with questions and multiple choice options.
    
    Args:
        senior_id: Unique identifier for the senior user
        
    Returns:
        QuizListResponse containing a QuizSession with questions
        
    Raises:
        HTTPException: If quiz retrieval fails
        
    Example:
        GET /quiz/list?senior_id=senior_123
        
    TODO: Future enhancements:
        - Fetch personalized quizzes based on senior_id from Firestore
        - Implement difficulty levels and adaptive quizzes
        - Track quiz history to avoid repeating recent questions
        - Generate dynamic quizzes using AI based on senior's profile
        - Support multiple quiz categories (memory, language, math, etc.)
    """
    try:
        logger.info(f"Fetching quiz for senior: {senior_id}")
        
        # TODO: For MVP, returning hardcoded quiz
        # In production, you would:
        # 1. Query Firestore for available quizzes
        # 2. Select appropriate quiz based on senior's history and level
        # 3. Filter out recently completed quizzes
        # 4. Personalize based on senior's cognitive assessment history
        
        # Create hardcoded quiz session for MVP
        quiz = QuizSession(
            id="quiz_001",
            title="기억력 평가",
            questions=[
                QuizQuestion(
                    id="q1",
                    question="오늘은 무슨 요일인가요?",
                    options=[
                        QuizQuestionOption(id="q1_opt1", text="월요일"),
                        QuizQuestionOption(id="q1_opt2", text="화요일"),
                        QuizQuestionOption(id="q1_opt3", text="수요일"),
                        QuizQuestionOption(id="q1_opt4", text="목요일"),
                    ]
                ),
                QuizQuestion(
                    id="q2",
                    question="다음 중 계절이 아닌 것은?",
                    options=[
                        QuizQuestionOption(id="q2_opt1", text="봄"),
                        QuizQuestionOption(id="q2_opt2", text="여름"),
                        QuizQuestionOption(id="q2_opt3", text="가을"),
                        QuizQuestionOption(id="q2_opt4", text="구름"),
                    ]
                ),
                QuizQuestion(
                    id="q3",
                    question="100에서 7을 빼면?",
                    options=[
                        QuizQuestionOption(id="q3_opt1", text="93"),
                        QuizQuestionOption(id="q3_opt2", text="92"),
                        QuizQuestionOption(id="q3_opt3", text="94"),
                        QuizQuestionOption(id="q3_opt4", text="91"),
                    ]
                ),
            ]
        )
        
        logger.info(f"Returning quiz: {quiz.id} with {len(quiz.questions)} questions")
        
        return QuizListResponse(
            success=True,
            quiz=quiz,
            message="Quiz retrieved successfully"
        )
    
    except Exception as e:
        logger.error(f"Failed to retrieve quiz: {e}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to retrieve quiz: {str(e)}"
        )


@router.post("/submit", response_model=QuizSubmitResponse)
async def submit_quiz(request: QuizSubmitRequest):
    """
    Submit quiz answers for evaluation.
    
    Stores the senior's quiz answers in Firestore for later analysis
    and cognitive assessment tracking.
    
    Args:
        request: Contains senior_id, quiz_id, and answers dictionary
        
    Returns:
        QuizSubmitResponse indicating successful submission
        
    Raises:
        HTTPException: If submission fails
        
    Example:
        POST /quiz/submit
        {
            "senior_id": "senior_123",
            "quiz_id": "quiz_001",
            "answers": {
                "q1": "q1_opt2",
                "q2": "q2_opt4",
                "q3": "q3_opt1"
            }
        }
        
    TODO: Future enhancements:
        - Validate answers against correct answers stored in Firestore
        - Calculate score and cognitive metrics
        - Provide immediate feedback on performance
        - Track performance trends over time
        - Trigger alerts if significant cognitive decline detected
        - Generate personalized recommendations based on results
        - Integrate with caregiver dashboard for monitoring
    """
    try:
        logger.info(
            f"Submitting quiz answers: senior={request.senior_id}, "
            f"quiz={request.quiz_id}, answers_count={len(request.answers)}"
        )
        
        # Validate that answers were provided
        if not request.answers:
            logger.warning("Quiz submission with empty answers")
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="No answers provided"
            )
        
        # Prepare quiz submission document
        quiz_submission = {
            "quizId": request.quiz_id,
            "answers": request.answers,
            "submittedAt": SERVER_TIMESTAMP,
        }
        
        # Store submission in Firestore under seniors/{senior_id}/quizzes/{quiz_id}
        quiz_ref = (
            db.collection('seniors')
            .document(request.senior_id)
            .collection('quizzes')
            .document(request.quiz_id)
        )
        
        quiz_ref.set(quiz_submission)
        
        logger.info(
            f"Successfully stored quiz submission: "
            f"seniors/{request.senior_id}/quizzes/{request.quiz_id}"
        )
        
        # TODO: In production, you would:
        # 1. Validate answers against correct answers from quiz definition
        # 2. Calculate score and accuracy metrics
        # 3. Compare with previous quiz results to track trends
        # 4. Update senior's cognitive profile
        # 5. Trigger notifications if concerning patterns detected
        # 6. Return score and feedback in the response
        
        return QuizSubmitResponse(
            success=True,
            message="Quiz submitted successfully"
        )
    
    except HTTPException:
        # Re-raise HTTP exceptions as-is
        raise
    
    except Exception as e:
        logger.error(f"Failed to submit quiz: {e}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to submit quiz: {str(e)}"
        )
