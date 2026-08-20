from pydantic import BaseModel
from typing import List


class ShoppingItem(BaseModel):
    name: str
    have: bool = False


class ShoppingListOut(BaseModel):
    items: List[ShoppingItem]


class GenerateFromRecipe(BaseModel):
    recipe_id: str
