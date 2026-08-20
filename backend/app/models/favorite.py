from pydantic import BaseModel
from typing import Optional


class FavoriteCreate(BaseModel):
    """
    Stores a snapshot of the recipe being favorited, since favorited
    recipes can come from Spoonacular (external, no permanent DB record)
    or from a user's own created recipes. Storing the snapshot means the
    Favorites screen never needs to re-fetch or join against another
    source to display the list.
    """
    recipe_id: str          # Spoonacular numeric id (as string) or our Mongo _id
    title: str
    image: Optional[str] = None
    cook_time: Optional[int] = None
    servings: Optional[int] = None
    source: str = "spoonacular"   # "spoonacular" | "user"


class FavoriteOut(FavoriteCreate):
    id: str