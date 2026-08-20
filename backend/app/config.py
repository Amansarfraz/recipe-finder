from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    mongo_uri: str = "mongodb://localhost:27017"
    mongo_db_name: str = "recipe_finder"
    jwt_secret: str = "change_this_secret_key"
    jwt_algorithm: str = "HS256"
    access_token_expire_minutes: int = 10080  # 7 days
    spoonacular_api_key: str = ""

    class Config:
        env_file = ".env"

settings = Settings()
