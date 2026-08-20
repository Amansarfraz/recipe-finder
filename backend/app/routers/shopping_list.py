from fastapi import APIRouter, Depends, HTTPException
from bson import ObjectId
from app.database import shopping_lists_collection, recipes_collection
from app.models.shopping_list import GenerateFromRecipe
from app.utils.deps import get_current_user

router = APIRouter(prefix="/shopping-list", tags=["shopping-list"])


@router.get("")
async def get_shopping_list(current_user: dict = Depends(get_current_user)):
    doc = await shopping_lists_collection.find_one({"user_id": current_user["_id"]})
    if not doc:
        return {"items": []}
    return {"items": doc.get("items", [])}


@router.post("/generate")
async def generate_from_recipe(payload: GenerateFromRecipe, current_user: dict = Depends(get_current_user)):
    recipe = await recipes_collection.find_one({"_id": ObjectId(payload.recipe_id)})
    if not recipe:
        raise HTTPException(status_code=404, detail="Recipe not found")

    new_items = [{"name": ing["name"], "have": False} for ing in recipe.get("ingredients", [])]

    existing = await shopping_lists_collection.find_one({"user_id": current_user["_id"]})
    if existing:
        existing_names = {item["name"].lower() for item in existing.get("items", [])}
        merged = existing.get("items", []) + [i for i in new_items if i["name"].lower() not in existing_names]
        await shopping_lists_collection.update_one(
            {"user_id": current_user["_id"]}, {"$set": {"items": merged}}
        )
        return {"items": merged}
    else:
        await shopping_lists_collection.insert_one({"user_id": current_user["_id"], "items": new_items})
        return {"items": new_items}


@router.patch("/{item_name}/toggle")
async def toggle_item(item_name: str, current_user: dict = Depends(get_current_user)):
    doc = await shopping_lists_collection.find_one({"user_id": current_user["_id"]})
    if not doc:
        raise HTTPException(status_code=404, detail="Shopping list not found")
    items = doc.get("items", [])
    for item in items:
        if item["name"].lower() == item_name.lower():
            item["have"] = not item["have"]
    await shopping_lists_collection.update_one({"user_id": current_user["_id"]}, {"$set": {"items": items}})
    return {"items": items}
