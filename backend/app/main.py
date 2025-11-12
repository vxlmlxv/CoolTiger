from fastapi import FastAPI

from .routers import analysis, conversation, health, scheduler

app = FastAPI(title="CoolTiger Backend", version="0.1.0")

app.include_router(health.router)
app.include_router(conversation.router, prefix="/api/v1", tags=["conversation"])
app.include_router(scheduler.router, prefix="/api/v1", tags=["scheduler"])
app.include_router(analysis.router, prefix="/api/v1", tags=["analysis"])
