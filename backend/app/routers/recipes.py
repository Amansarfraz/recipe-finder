import re
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


def _full_image_url(recipe_id) -> str:
    return f"https://img.spoonacular.com/recipes/{recipe_id}-556x370.jpg"


def _difficulty_for(minutes) -> str:
    if minutes is None:
        return "Medium"
    if minutes <= 20:
        return "Easy"
    if minutes <= 45:
        return "Medium"
    return "Hard"


async def _find_and_enrich(ing_list: list[str], max_ready_time: Optional[int] = None, number: int = 10):
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


@router.get("/search-by-name")
async def search_by_name(
    query: str,
    cuisine: Optional[str] = "Any",
    max_ready_time: Optional[int] = None,
    max_calories: Optional[int] = None,
    sort_by: Optional[str] = None,
    number: int = 20,
):
    try:
        result = await spoonacular_service.complex_search(
            query=query,
            cuisine=cuisine,
            max_ready_time=max_ready_time,
            max_calories=max_calories,
            sort=sort_by,
            number=number,
        )
    except Exception as e:
        raise HTTPException(status_code=502, detail=f"Search failed: {str(e)}")

    results = []
    for r in result.get("results", []):
        ready_in = r.get("readyInMinutes")
        score = r.get("spoonacularScore")
        rating = round(score / 20, 1) if score is not None else None
        results.append({
            "id": r["id"],
            "title": r.get("title"),
            "image": _full_image_url(r["id"]),
            "readyInMinutes": ready_in,
            "servings": r.get("servings"),
            "difficulty": _difficulty_for(ready_in),
            "rating": rating,
        })

    return {
        "results": results,
        "total_results": result.get("totalResults", len(results)),
    }


@router.get("/external/{recipe_id}")
async def get_external_recipe_details(recipe_id: int):
    try:
        info = await spoonacular_service.get_recipe_information(recipe_id)
    except Exception as e:
        raise HTTPException(status_code=502, detail=f"Could not fetch recipe: {str(e)}")

    ingredients = [
        {
            "name": ing.get("name", "").title() or ing.get("original", ""),
            "amount": f"{ing.get('amount', '')} {ing.get('unit', '')}".strip(),
        }
        for ing in info.get("extendedIngredients", [])
    ]

    instructions = []
    analyzed = info.get("analyzedInstructions", [])
    if analyzed and analyzed[0].get("steps"):
        instructions = [step.get("step", "") for step in analyzed[0]["steps"]]
    elif info.get("instructions"):
        raw = re.sub("<[^<]+?>", "", info["instructions"])
        instructions = [s.strip() for s in raw.split(".") if s.strip()]

    nutrition = {}
    for n in info.get("nutrition", {}).get("nutrients", []):
        if n.get("name") in ("Calories", "Protein", "Carbohydrates", "Fat"):
            nutrition[n["name"]] = f"{round(n.get('amount', 0))}{n.get('unit', '')}"

    ready_in = info.get("readyInMinutes")

    return {
        "title": info.get("title"),
        "image": _full_image_url(recipe_id),
        "readyInMinutes": ready_in,
        "servings": info.get("servings"),
        "difficulty": _difficulty_for(ready_in),
        "ingredients": ingredients,
        "instructions": instructions,
        "nutrition": nutrition,
    }


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
    doc.pop("_id", None)
    return doc