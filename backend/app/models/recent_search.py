from pydantic import BaseModel


class RecentSearchCreate(BaseModel):
    query: str   # e.g. "chicken, tomato, onion"


class RecentSearchOut(RecentSearchCreate):
    id: str
    created_at: str