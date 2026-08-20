from pydantic import BaseModel, Field
from typing import Optional, List


class RecipeIngredient(BaseModel):
    name: str
    amount: Optional[str] = None


class RecipeCreate(BaseModel):
    title: str
    photo_url: Optional[str] = None
    ingredients: List[RecipeIngredient]
    steps: List[str]
    cuisine: Optional[str] = "Any"
    diet_type: Optional[str] = "Any"
    cook_time: Optional[int] = None   # minutes
    calories: Optional[int] = None
    difficulty: Optional[str] = "Medium"
    servings: Optional[int] = 1


class RecipeOut(RecipeCreate):
    id: str
    created_by: Optional[str] = None
    source: str = "user"           # "user" | "spoonacular"
    rating_avg: float = 0.0
    rating_count: int = 0


class AIRecipeRequest(BaseModel):
    ingredients: List[str]
    diet_type: Optional[str] = "Any"
    cuisine: Optional[str] = "Any"
    max_cook_time: Optional[int] = 30
