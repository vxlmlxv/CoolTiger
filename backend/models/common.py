"""
Common response models for API endpoints.

This module defines shared Pydantic models used across the FastAPI backend
for standardized API responses.
"""

from typing import Generic, TypeVar

from pydantic import BaseModel


class BaseResponse(BaseModel):
    """
    Base response model for simple API responses.
    
    Use this for endpoints that only need to indicate success/failure
    with an optional message.
    
    Attributes:
        success: Whether the operation was successful
        message: Optional message providing additional context
        
    Example:
        >>> response = BaseResponse(success=True, message="Operation completed")
        >>> response = BaseResponse(success=False, message="Error occurred")
    """
    success: bool
    message: str | None = None


T = TypeVar("T")


class DataResponse(BaseModel, Generic[T]):
    """
    Generic response model for API responses with data payload.
    
    Use this for endpoints that return data along with success/failure status.
    The generic type parameter T allows type-safe data payloads.
    
    Attributes:
        success: Whether the operation was successful
        data: The response data payload (type varies based on generic parameter)
        message: Optional message providing additional context
        
    Example:
        >>> from pydantic import BaseModel
        >>> class User(BaseModel):
        ...     id: str
        ...     name: str
        >>> 
        >>> response = DataResponse[User](
        ...     success=True,
        ...     data=User(id="123", name="John"),
        ...     message="User retrieved successfully"
        ... )
        >>> response = DataResponse[list[str]](
        ...     success=True,
        ...     data=["item1", "item2"],
        ... )
    """
    success: bool
    data: T | None = None
    message: str | None = None
