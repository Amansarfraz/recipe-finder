from pydantic import BaseModel, Field
from typing import Optional


class CommentCreate(BaseModel):
    text: str
    rating: int = Field(..., ge=1, le=5)


class CommentOut(BaseModel):
    id: str
    recipe_id: str
    user_id: str
    user_name: Optional[str] = None
    text: str
    rating: int
    created_at: str
