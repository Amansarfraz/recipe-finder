from fastapi import APIRouter, Depends, HTTPException
from bson import ObjectId
from app.database import shopping_lists_collection, recipes_collection
from app.models.shopping_list import GenerateFromRecipe, AddIngredients, AddItem
from app.utils.deps import get_current_user

router = APIRouter(prefix="/shopping-list", tags=["shopping-list"])


async def _get_items(user_id: str):
    doc = await shopping_lists_collection.find_one({"user_id": user_id})
    return doc.get("items", []) if doc else []


async def _save_items(user_id: str, items: list):
    await shopping_lists_collection.update_one(
        {"user_id": user_id}, {"$set": {"items": items}}, upsert=True
    )


@router.get("")
async def get_shopping_list(current_user: dict = Depends(get_current_user)):
    return {"items": await _get_items(current_user["_id"])}


@router.post("/generate")
async def generate_from_recipe(payload: GenerateFromRecipe, current_user: dict = Depends(get_current_user)):
    recipe = await recipes_collection.find_one({"_id": ObjectId(payload.recipe_id)})
    if not recipe:
        raise HTTPException(status_code=404, detail="Recipe not found")

    new_names = [ing["name"] for ing in recipe.get("ingredients", [])]
    return await _merge_and_save(current_user["_id"], new_names)


@router.post("/add-ingredients")
async def add_ingredients(payload: AddIngredients, current_user: dict = Depends(get_current_user)):
    return await _merge_and_save(current_user["_id"], payload.ingredients)


async def _merge_and_save(user_id: str, new_names: list[str]):
    existing = await _get_items(user_id)
    existing_lower = {item["name"].lower() for item in existing}
    added = [{"name": n, "have": False} for n in new_names if n.lower() not in existing_lower]
    merged = existing + added
    await _save_items(user_id, merged)
    return {"items": merged}


@router.post("/items")
async def add_item(payload: AddItem, current_user: dict = Depends(get_current_user)):
    items = await _get_items(current_user["_id"])
    if any(i["name"].lower() == payload.name.lower() for i in items):
        raise HTTPException(status_code=400, detail="Item already on the list")
    items.append({"name": payload.name, "have": False})
    await _save_items(current_user["_id"], items)
    return {"items": items}


@router.delete("/items/{item_name}")
async def remove_item(item_name: str, current_user: dict = Depends(get_current_user)):
    items = await _get_items(current_user["_id"])
    filtered = [i for i in items if i["name"].lower() != item_name.lower()]
    if len(filtered) == len(items):
        raise HTTPException(status_code=404, detail="Item not found")
    await _save_items(current_user["_id"], filtered)
    return {"items": filtered}


@router.delete("")
async def clear_list(current_user: dict = Depends(get_current_user)):
    await _save_items(current_user["_id"], [])
    return {"items": []}


@router.patch("/{item_name}/toggle")
async def toggle_item(item_name: str, current_user: dict = Depends(get_current_user)):
    items = await _get_items(current_user["_id"])
    found = False
    for item in items:
        if item["name"].lower() == item_name.lower():
            item["have"] = not item["have"]
            found = True
    if not found:
        raise HTTPException(status_code=404, detail="Item not found")
    await _save_items(current_user["_id"], items)
    return {"items": items}