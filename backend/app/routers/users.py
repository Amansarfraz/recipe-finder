from fastapi import APIRouter, Depends
from app.database import users_collection
from app.models.user import UserUpdate, UserOut
from app.utils.deps import get_current_user
from bson import ObjectId

router = APIRouter(prefix="/users", tags=["users"])


@router.get("/me", response_model=UserOut)
async def get_me(current_user: dict = Depends(get_current_user)):
    return UserOut(
        id=current_user["_id"],
        name=current_user["name"],
        email=current_user["email"],
        profile_photo=current_user.get("profile_photo"),
        dietary_prefs=current_user.get("dietary_prefs", []),
    )


@router.patch("/me", response_model=UserOut)
async def update_me(payload: UserUpdate, current_user: dict = Depends(get_current_user)):
    updates = {k: v for k, v in payload.model_dump().items() if v is not None}
    if updates:
        await users_collection.update_one({"_id": ObjectId(current_user["_id"])}, {"$set": updates})
    updated = await users_collection.find_one({"_id": ObjectId(current_user["_id"])})
    return UserOut(
        id=str(updated["_id"]),
        name=updated["name"],
        email=updated["email"],
        profile_photo=updated.get("profile_photo"),
        dietary_prefs=updated.get("dietary_prefs", []),
    )
