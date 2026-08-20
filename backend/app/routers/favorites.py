from fastapi import APIRouter, Depends, HTTPException
from bson import ObjectId
from app.database import favorites_collection, recipes_collection
from app.utils.deps import get_current_user

router = APIRouter(prefix="/favorites", tags=["favorites"])


@router.get("")
async def get_favorites(current_user: dict = Depends(get_current_user)):
    cursor = favorites_collection.find({"user_id": current_user["_id"]})
    recipe_ids = [ObjectId(fav["recipe_id"]) async for fav in cursor]
    recipes = await recipes_collection.find({"_id": {"$in": recipe_ids}}).to_list(length=None)
    for r in recipes:
        r["id"] = str(r["_id"])
        r.pop("_id", None)
    return recipes


@router.post("/{recipe_id}")
async def add_favorite(recipe_id: str, current_user: dict = Depends(get_current_user)):
    existing = await favorites_collection.find_one({"user_id": current_user["_id"], "recipe_id": recipe_id})
    if existing:
        raise HTTPException(status_code=400, detail="Already in favorites")
    await favorites_collection.insert_one({"user_id": current_user["_id"], "recipe_id": recipe_id})
    return {"message": "Added to favorites"}


@router.delete("/{recipe_id}")
async def remove_favorite(recipe_id: str, current_user: dict = Depends(get_current_user)):
    result = await favorites_collection.delete_one({"user_id": current_user["_id"], "recipe_id": recipe_id})
    if result.deleted_count == 0:
        raise HTTPException(status_code=404, detail="Favorite not found")
    return {"message": "Removed from favorites"}
