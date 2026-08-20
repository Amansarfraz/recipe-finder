from fastapi import APIRouter, HTTPException, status
from app.database import users_collection
from app.models.user import UserSignup, UserLogin, Token, UserOut
from app.utils.security import hash_password, verify_password, create_access_token

router = APIRouter(prefix="/auth", tags=["auth"])


@router.post("/signup", response_model=Token)
async def signup(payload: UserSignup):
    existing = await users_collection.find_one({"email": payload.email})
    if existing:
        raise HTTPException(status_code=400, detail="Email already registered")

    user_doc = {
        "name": payload.name,
        "email": payload.email,
        "password_hash": hash_password(payload.password),
        "profile_photo": None,
        "dietary_prefs": [],
    }
    result = await users_collection.insert_one(user_doc)
    user_id = str(result.inserted_id)
    token = create_access_token({"user_id": user_id})
    user_out = UserOut(id=user_id, name=payload.name, email=payload.email)
    return Token(access_token=token, user=user_out)


@router.post("/login", response_model=Token)
async def login(payload: UserLogin):
    user = await users_collection.find_one({"email": payload.email})
    if not user or not verify_password(payload.password, user["password_hash"]):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid email or password")

    token = create_access_token({"user_id": str(user["_id"])})
    user_out = UserOut(
        id=str(user["_id"]),
        name=user["name"],
        email=user["email"],
        profile_photo=user.get("profile_photo"),
        dietary_prefs=user.get("dietary_prefs", []),
    )
    return Token(access_token=token, user=user_out)


@router.post("/forgot-password")
async def forgot_password(email: str):
    user = await users_collection.find_one({"email": email})
    if not user:
        # Don't reveal whether email exists
        return {"message": "If that email exists, a reset link has been sent"}
    # TODO: integrate email service (SendGrid/SES) to send reset token/link
    return {"message": "If that email exists, a reset link has been sent"}
