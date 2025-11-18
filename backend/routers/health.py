"""
Health check router for monitoring service availability.

This module provides a simple endpoint to verify that the API is running
and responsive.
"""

from fastapi import APIRouter

# Create health check router
router = APIRouter(prefix="/health", tags=["health"])


@router.get("/")
async def health_check():
    """
    Health check endpoint.
    
    Returns a simple status indicator to confirm the API is operational.
    This endpoint is typically used by load balancers, monitoring systems,
    and container orchestration platforms to verify service health.
    
    Returns:
        dict: Status response with "ok" indicator
        
    Example:
        GET /health/
        Response: {"status": "ok"}
    """
    return {"status": "ok"}
