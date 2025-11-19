"""
FastAPI backend application for Hyosimi - AI senior care system.

This is the main entry point for the FastAPI backend server.
It configures middleware, includes routers, and defines the application instance.

To run the development server:
    uvicorn main:app --reload

To run with custom host and port:
    uvicorn main:app --host 0.0.0.0 --port 8000

For production deployment:
    uvicorn main:app --host 0.0.0.0 --port 8000 --workers 4
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from config import settings
from routers import health, conversation, quiz

# Create FastAPI application instance
app = FastAPI(
    title=settings.app_name,
    description="Backend API for Hyosimi - AI-powered senior care and conversation system",
    version="1.0.0",
)

# Configure CORS middleware
# TODO: Restrict origins in production to specific domains
# For MVP, allowing all origins for easier frontend development
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # TODO: Replace with specific origins in production (e.g., ["https://yourdomain.com"])
    allow_credentials=True,
    allow_methods=["*"],  # Allows all HTTP methods (GET, POST, PUT, DELETE, etc.)
    allow_headers=["*"],  # Allows all headers
)

# Include routers
app.include_router(health.router)
app.include_router(conversation.router)
app.include_router(quiz.router)


@app.get("/")
async def root():
    """
    Root endpoint for the API.
    
    Returns a simple welcome message to verify the server is running.
    
    Returns:
        dict: Welcome message with application name
        
    Example:
        GET /
        Response: {"message": "CoolTiger backend is running"}
    """
    return {"message": "CoolTiger backend is running"}