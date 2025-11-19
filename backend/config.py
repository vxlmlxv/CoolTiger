"""
Configuration module for the FastAPI backend application.

This module uses pydantic-settings to load configuration from environment variables
and a .env file located in the backend root directory.
"""

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """
    Application settings loaded from environment variables and .env file.
    
    All configuration values are loaded from the .env file in the backend root directory.
    Fields with default values will use those defaults if not specified in the environment.
    """
    
    # Application settings
    env: str = "development"
    
    app_name: str = "cooltiger-backend"
    """Application name"""
    
    port: str = "8000"
    
    # Google Cloud settings
    google_project_id: str | None = None
    """Google Cloud project ID"""
    
    google_application_credentials: str | None = None
    """Path to Google Cloud service account credentials JSON file"""
    
    # Google Text-to-Speech settings
    google_tts_language_code: str | None = None
    """Language code for Google TTS (e.g., en-US, ko-KR)"""
    
    google_tts_voice_name: str | None = None
    """Voice name for Google TTS"""
    

    
    # Clova Speech settings
    clova_speech_endpoint: str | None = None
    """Endpoint URL for Clova Speech API"""
    
    clova_speech_api_key: str | None = None
    """API key for Clova Speech"""
    
    # Clova Studio settings
    clova_studio_endpoint: str | None = None
    """Endpoint URL for Clova Studio API"""
    
    clova_studio_api_key: str | None = None
    """API key for Clova Studio"""
    
    clova_studio_api_secret: str | None = None
    """Secret key for Clova Studio"""
    
    clova_studio_request_id: str | None = None
    """Request ID for Clova Studio"""
    
    # Backend security
    backend_api_key: str | None = None
    """API key for backend authentication"""
    
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore"
    )


# Singleton instance of settings
settings = Settings()
