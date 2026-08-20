from fastapi import APIRouter, Depends
from datetime import datetime
from app.database import recent_searches_collection
from app.models.recent_search import RecentSearchCreate
from app.utils.deps import get_current_user

router = APIRouter(prefix="/recent-searches", tags=["recent-searches"])

MAX_RECENT = 10


@router.get("")
async def get_recent_searches(current_user: dict = Depends(get_current_user)):
    cursor = recent_searches_collection.find(
        {"user_id": current_user["_id"]}
    ).sort("created_at", -1).limit(MAX_RECENT)
    results = []
    async for doc in cursor:
        doc["id"] = str(doc["_id"])
        doc.pop("_id", None)
        doc.pop("user_id", None)
        results.append(doc)
    return results


@router.post("")
async def log_recent_search(payload: RecentSearchCreate, current_user: dict = Depends(get_current_user)):
    # Avoid storing an exact duplicate of the most recent entry back-to-back
    last = await recent_searches_collection.find_one(
        {"user_id": current_user["_id"]}, sort=[("created_at", -1)]
    )
    if last and last.get("query") == payload.query:
        return {"message": "Duplicate of last search, not logged"}

    doc = {
        "user_id": current_user["_id"],
        "query": payload.query,
        "created_at": datetime.utcnow().isoformat(),
    }
    await recent_searches_collection.insert_one(doc)

    # Trim to the most recent MAX_RECENT entries for this user
    cursor = recent_searches_collection.find(
        {"user_id": current_user["_id"]}
    ).sort("created_at", -1).skip(MAX_RECENT)
    old_ids = [d["_id"] async for d in cursor]
    if old_ids:
        await recent_searches_collection.delete_many({"_id": {"$in": old_ids}})

    return {"message": "Logged"}