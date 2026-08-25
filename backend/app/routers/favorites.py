from fastapi import APIRouter, Depends, HTTPException
from app.database import favorites_collection
from app.models.favorite import FavoriteCreate
from app.utils.deps import get_current_user

router = APIRouter(prefix="/favorites", tags=["favorites"])


def serialize_favorite(doc) -> dict:
    doc["id"] = str(doc["_id"])
    doc.pop("_id", None)
    doc.pop("user_id", None)
    return doc


@router.get("")
async def get_favorites(current_user: dict = Depends(get_current_user)):
    cursor = favorites_collection.find({"user_id": current_user["_id"]}).sort("_id", -1)
    return [serialize_favorite(doc) async for doc in cursor]


@router.post("")
async def add_favorite(payload: FavoriteCreate, current_user: dict = Depends(get_current_user)):
    existing = await favorites_collection.find_one({
        "user_id": current_user["_id"],
        "recipe_id": payload.recipe_id,
    })
    if existing:
        raise HTTPException(status_code=400, detail="Already in favorites")

    doc = payload.model_dump()
    doc["user_id"] = current_user["_id"]
    result = await favorites_collection.insert_one(doc)
    doc["id"] = str(result.inserted_id)
    doc.pop("_id", None)
    doc.pop("user_id", None)
    return doc


@router.delete("/{recipe_id}")
async def remove_favorite(recipe_id: str, current_user: dict = Depends(get_current_user)):
    result = await favorites_collection.delete_one({
        "user_id": current_user["_id"],
        "recipe_id": recipe_id,
    })
    if result.deleted_count == 0:
        raise HTTPException(status_code=404, detail="Favorite not found")
    return {"message": "Removed from favorites"}