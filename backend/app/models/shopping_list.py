from pydantic import BaseModel
from typing import List, Optional


class ShoppingItem(BaseModel):
    name: str
    have: bool = False


class ShoppingListOut(BaseModel):
    items: List[ShoppingItem]


class GenerateFromRecipe(BaseModel):
    recipe_id: str


class AddIngredients(BaseModel):
    """Add a batch of ingredient names directly — used when generating
    a shopping list from an external (Spoonacular) recipe, since those
    aren't stored in our own recipes collection and have no Mongo id."""
    ingredients: List[str]


class AddItem(BaseModel):
    name: str