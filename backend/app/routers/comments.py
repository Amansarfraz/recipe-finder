from fastapi import APIRouter, Depends
from datetime import datetime
from app.database import comments_collection
from app.models.comment import CommentCreate
from app.utils.deps import get_current_user

router = APIRouter(prefix="/recipes", tags=["comments"])


@router.post("/{recipe_id}/comments")
async def add_comment(recipe_id: str, payload: CommentCreate, current_user: dict = Depends(get_current_user)):
    doc = {
        "recipe_id": recipe_id,
        "user_id": current_user["_id"],
        "user_name": current_user.get("name"),
        "text": payload.text,
        "rating": payload.rating,
        "created_at": datetime.utcnow().isoformat(),
    }
    result = await comments_collection.insert_one(doc)
    doc["id"] = str(result.inserted_id)
    return doc


@router.get("/{recipe_id}/comments")
async def get_comments(recipe_id: str):
    cursor = comments_collection.find({"recipe_id": recipe_id}).sort("created_at", -1)
    comments = []
    async for c in cursor:
        c["id"] = str(c["_id"])
        c.pop("_id", None)
        comments.append(c)
    return comments
