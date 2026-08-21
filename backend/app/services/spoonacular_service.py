import httpx
from app.config import settings

BASE_URL = "https://api.spoonacular.com"


async def search_by_ingredients(ingredients: list[str], number: int = 10):
    params = {
        "apiKey": settings.spoonacular_api_key,
        "ingredients": ",".join(ingredients),
        "number": number,
        "ranking": 1,
        "ignorePantry": True,
    }
    async with httpx.AsyncClient() as client:
        resp = await client.get(f"{BASE_URL}/recipes/findByIngredients", params=params)
        resp.raise_for_status()
        return resp.json()


async def get_recipe_information(recipe_id: int):
    params = {"apiKey": settings.spoonacular_api_key, "includeNutrition": True}
    async with httpx.AsyncClient() as client:
        resp = await client.get(f"{BASE_URL}/recipes/{recipe_id}/information", params=params)
        resp.raise_for_status()
        return resp.json()


async def get_bulk_recipe_information(recipe_ids: list[int]):
    if not recipe_ids:
        return []
    params = {
        "apiKey": settings.spoonacular_api_key,
        "ids": ",".join(str(i) for i in recipe_ids),
    }
    async with httpx.AsyncClient() as client:
        resp = await client.get(f"{BASE_URL}/recipes/informationBulk", params=params)
        resp.raise_for_status()
        return resp.json()


async def complex_search(ingredients: list[str], diet: str = None, cuisine: str = None, max_ready_time: int = None, number: int = 10):
    params = {
        "apiKey": settings.spoonacular_api_key,
        "includeIngredients": ",".join(ingredients) if ingredients else None,
        "diet": None if not diet or diet.lower() == "any" else diet,
        "cuisine": None if not cuisine or cuisine.lower() == "any" else cuisine,
        "maxReadyTime": max_ready_time,
        "number": number,
        "addRecipeInformation": True,
    }
    params = {k: v for k, v in params.items() if v is not None}
    async with httpx.AsyncClient() as client:
        resp = await client.get(f"{BASE_URL}/recipes/complexSearch", params=params)
        resp.raise_for_status()
        return resp.json()