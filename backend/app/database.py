from motor.motor_asyncio import AsyncIOMotorClient
from app.config import settings

client = AsyncIOMotorClient(settings.mongo_uri)
db = client[settings.mongo_db_name]

users_collection = db["users"]
recipes_collection = db["recipes"]
favorites_collection = db["favorites"]
comments_collection = db["comments"]
shopping_lists_collection = db["shopping_lists"]
notifications_collection = db["notifications"]
recent_searches_collection = db["recent_searches"]