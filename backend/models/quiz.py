"""
Quiz models for cognitive assessment feature.

This module defines Pydantic models for managing quiz sessions, questions,
and answer submissions for senior cognitive assessments.
"""

from pydantic import BaseModel


class QuizQuestionOption(BaseModel):
    """
    A single option for a quiz question.
    
    Attributes:
        id: Unique identifier for this option
        text: Display text for the option
        
    Example:
        >>> option = QuizQuestionOption(id="opt_1", text="Spring")
    """
    id: str
    text: str


class QuizQuestion(BaseModel):
    """
    A quiz question with multiple choice options.
    
    Attributes:
        id: Unique identifier for this question
        question: The question text to display
        options: List of available answer options
        
    Example:
        >>> question = QuizQuestion(
        ...     id="q1",
        ...     question="What season comes after winter?",
        ...     options=[
        ...         QuizQuestionOption(id="opt_1", text="Spring"),
        ...         QuizQuestionOption(id="opt_2", text="Summer")
        ...     ]
        ... )
    """
    id: str
    question: str
    options: list[QuizQuestionOption]


class QuizSession(BaseModel):
    """
    A complete quiz session with multiple questions.
    
    Represents a full cognitive assessment quiz that can be presented
    to a senior user.
    
    Attributes:
        id: Unique identifier for this quiz session
        title: Display title for the quiz
        questions: List of questions in this quiz
        
    Example:
        >>> quiz = QuizSession(
        ...     id="quiz_123",
        ...     title="Memory Assessment",
        ...     questions=[
        ...         QuizQuestion(id="q1", question="What is 2+2?", options=[...]),
        ...         QuizQuestion(id="q2", question="Name this color", options=[...])
        ...     ]
        ... )
    """
    id: str
    title: str
    questions: list[QuizQuestion]


class QuizListResponse(BaseModel):
    """
    Response model for retrieving a quiz.
    
    Contains the quiz session data or error information.
    
    Attributes:
        success: Whether the quiz was successfully retrieved
        quiz: The quiz session data if successful
        message: Optional message with additional context or error details
        
    Example:
        >>> response = QuizListResponse(
        ...     success=True,
        ...     quiz=QuizSession(id="quiz_123", title="Memory Test", questions=[...])
        ... )
        >>> error_response = QuizListResponse(
        ...     success=False,
        ...     message="Quiz not found"
        ... )
    """
    success: bool
    quiz: QuizSession | None = None
    message: str | None = None


class QuizSubmitRequest(BaseModel):
    """
    Request model for submitting quiz answers.
    
    Attributes:
        senior_id: Unique identifier for the senior user
        quiz_id: Unique identifier for the quiz session
        answers: Dictionary mapping question IDs to selected option IDs
        
    Example:
        >>> request = QuizSubmitRequest(
        ...     senior_id="senior_123",
        ...     quiz_id="quiz_456",
        ...     answers={
        ...         "q1": "opt_1",
        ...         "q2": "opt_3",
        ...         "q3": "opt_2"
        ...     }
        ... )
    """
    senior_id: str
    quiz_id: str
    answers: dict[str, str]


class QuizSubmitResponse(BaseModel):
    """
    Response model for quiz submission endpoint.
    
    Indicates whether the quiz answers were successfully recorded.
    
    Attributes:
        success: Whether the submission was successfully processed
        message: Optional message with additional context or error details
        
    Example:
        >>> response = QuizSubmitResponse(
        ...     success=True,
        ...     message="Quiz submitted successfully"
        ... )
        >>> error_response = QuizSubmitResponse(
        ...     success=False,
        ...     message="Invalid quiz session"
        ... )
    """
    success: bool
    message: str | None = None
