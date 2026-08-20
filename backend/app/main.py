from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.routers import (
    auth,
    recipes,
    favorites,
    comments,
    shopping_list,
    users,
    notifications,
    recent_searches,
)

app = FastAPI(title="Recipe Finder API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # restrict in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router)
app.include_router(recipes.router)
app.include_router(favorites.router)
app.include_router(comments.router)
app.include_router(shopping_list.router)
app.include_router(users.router)
app.include_router(notifications.router)
app.include_router(recent_searches.router)


@app.get("/")
async def root():
    return {"message": "Recipe Finder API running"}