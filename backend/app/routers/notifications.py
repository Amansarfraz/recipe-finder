from fastapi import APIRouter, Depends
from app.database import notifications_collection
from app.utils.deps import get_current_user

router = APIRouter(prefix="/notifications", tags=["notifications"])


@router.get("")
async def get_notifications(current_user: dict = Depends(get_current_user)):
    cursor = notifications_collection.find({"user_id": current_user["_id"]}).sort("created_at", -1)
    items = []
    async for n in cursor:
        n["id"] = str(n["_id"])
        n.pop("_id", None)
        items.append(n)
    return items


@router.patch("/{notification_id}/read")
async def mark_read(notification_id: str, current_user: dict = Depends(get_current_user)):
    from bson import ObjectId
    await notifications_collection.update_one(
        {"_id": ObjectId(notification_id), "user_id": current_user["_id"]},
        {"$set": {"read": True}},
    )
    return {"message": "Marked as read"}
