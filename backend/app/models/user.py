from pydantic import BaseModel, EmailStr, Field
from typing import Optional, List


class UserSignup(BaseModel):
    name: str
    email: EmailStr
    password: str


class UserLogin(BaseModel):
    email: EmailStr
    password: str


class UserOut(BaseModel):
    id: str
    name: str
    email: EmailStr
    profile_photo: Optional[str] = None
    dietary_prefs: List[str] = []


class UserUpdate(BaseModel):
    name: Optional[str] = None
    profile_photo: Optional[str] = None
    dietary_prefs: Optional[List[str]] = None


class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: UserOut
