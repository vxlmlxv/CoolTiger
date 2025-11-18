# Use Python 3.11 slim image as base
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Set environment variables
# Prevents Python from writing pyc files to disc
ENV PYTHONDONTWRITEBYTECODE=1
# Prevents Python from buffering stdout and stderr
ENV PYTHONUNBUFFERED=1

# Copy requirements file
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Expose port (default 8000, but will use $PORT from environment)
EXPOSE 8000

# Run the application
# Uses $PORT environment variable for cloud deployment (e.g., Cloud Run, Heroku)
CMD uvicorn main:app --host 0.0.0.0 --port ${PORT:-8000}
