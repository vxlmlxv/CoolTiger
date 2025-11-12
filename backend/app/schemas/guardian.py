from __future__ import annotations

from pydantic import BaseModel, EmailStr

class Guardian(BaseModel):
    id: str
    email: EmailStr
    name: str
