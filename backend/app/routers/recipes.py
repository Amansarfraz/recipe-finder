from fastapi import APIRouter, Depends, HTTPException
from bson import ObjectId
from typing import Optional
from app.database import recipes_collection
from app.models.recipe import RecipeCreate, AIRecipeRequest
from app.utils.deps import get_current_user
from app.services import spoonacular_service

router = APIRouter(prefix="/recipes", tags=["recipes"])


def serialize_recipe(doc) -> dict:
    doc["id"] = str(doc["_id"])
    doc.pop("_id", None)
    return doc


def _full_image_url(recipe_id: int) -> str:
    """
    findByIngredients only returns a bare filename (or nothing usable) in
    its 'image' field, not a full URL. Spoonacular's CDN uses a
    predictable pattern keyed by recipe id, so we build the URL directly
    instead of trusting whatever 'image' contains.
    """
    return f"https://img.spoonacular.com/recipes/{recipe_id}-556x370.jpg"


async def _find_and_enrich(ing_list: list[str], max_ready_time: Optional[int] = None, number: int = 10):
    """
    Uses findByIngredients (forgiving match — works with whatever
    ingredients are actually available, doesn't require every single
    one to appear), then enriches with cook time / servings via a
    bulk info call, and builds a correct, fully-qualified image URL.
    """
    matches = await spoonacular_service.search_by_ingredients(ing_list, number=number)
    if not matches:
        return []

    ids = [m["id"] for m in matches]
    try:
        info = await spoonacular_service.get_bulk_recipe_information(ids)
    except Exception:
        info = []

    info_by_id = {item["id"]: item for item in info}

    enriched = []
    for m in matches:
        details = info_by_id.get(m["id"], {})
        ready_in = details.get("readyInMinutes")
        if max_ready_time and ready_in and ready_in > max_ready_time:
            continue
        enriched.append({
            "id": m["id"],
            "title": m.get("title"),
            "image": _full_image_url(m["id"]),
            "usedIngredientCount": m.get("usedIngredientCount"),
            "missedIngredientCount": m.get("missedIngredientCount"),
            "readyInMinutes": ready_in,
            "servings": details.get("servings"),
        })
    return enriched


@router.get("/search")
async def search_recipes(ingredients: str, diet_type: Optional[str] = "Any",
                          cuisine: Optional[str] = "Any", max_cook_time: Optional[int] = None):
    ing_list = [i.strip() for i in ingredients.split(",") if i.strip()]

    cursor = recipes_collection.find(
        {"ingredients.name": {"$regex": "|".join(ing_list), "$options": "i"}}
    ) if ing_list else recipes_collection.find({})
    user_recipes = [serialize_recipe(doc) async for doc in cursor]

    external = []
    try:
        external = await _find_and_enrich(ing_list, max_ready_time=max_cook_time)
    except Exception:
        external = []

    return {"user_recipes": user_recipes, "external_recipes": external}


@router.post("/ai-generate")
async def ai_generate_recipe(payload: AIRecipeRequest):
    try:
        return await _find_and_enrich(payload.ingredients, max_ready_time=payload.max_cook_time)
    except Exception as e:
        raise HTTPException(status_code=502, detail=f"AI recipe generation failed: {str(e)}")


@router.get("/{recipe_id}")
async def get_recipe(recipe_id: str):
    doc = await recipes_collection.find_one({"_id": ObjectId(recipe_id)})
    if not doc:
        raise HTTPException(status_code=404, detail="Recipe not found")
    return serialize_recipe(doc)


@router.post("")
async def create_recipe(payload: RecipeCreate, current_user: dict = Depends(get_current_user)):
    doc = payload.model_dump()
    doc["created_by"] = current_user["_id"]
    doc["source"] = "user"
    doc["rating_avg"] = 0.0
    doc["rating_count"] = 0
    result = await recipes_collection.insert_one(doc)
    doc["id"] = str(result.inserted_id)
    return doc