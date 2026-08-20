# Smart Recipe Finder — Full Stack

## Stack
- **Frontend:** Flutter (Provider state management) — VS Code
- **Backend:** Python FastAPI (async, Motor for MongoDB)
- **Database:** MongoDB

## Structure
```
recipe-finder/
├── backend/     → FastAPI app (auth, recipes, favorites, comments, shopping-list, users, notifications)
└── frontend/    → Flutter app (matches orange "Smart Recipe Finder" brand)
```

## Run Backend
```bash
cd backend
python -m venv venv
source venv/bin/activate      # Windows: venv\Scripts\activate
pip install -r requirements.txt
cp .env.example .env          # fill in Mongo URI + Spoonacular API key
uvicorn app.main:app --reload
```
API docs: http://localhost:8000/docs

## Run Frontend
```bash
cd frontend
flutter pub get
flutter run
```
Update `lib/core/constants.dart` → `baseUrl` if not using Android emulator default (`10.0.2.2:8000`).

## What's Built So Far
- Backend: full auth (signup/login/forgot-password), recipe search (user DB + Spoonacular), AI recipe generation endpoint, favorites, comments/ratings, shopping list, user profile, notifications — all MongoDB-backed.
- Frontend: Signup, Login, "What ingredients do you have?" screen, Search/Filter results screen (**re-themed orange** — was blue in the Figma draft), Add Recipe screen, reusable RecipeCard + IngredientChip widgets, orange AppTheme, API client with JWT auth, Provider-based Auth & Recipe state.

## Still To Build (next round)
- Recipe Detail screen (tabs: Ingredients/Instructions/Nutrition + comments)
- My Favorites screen (tabbed: All/Breakfast/Dinner/Desserts)
- AI Recipe Generator screen (ingredient chips + diet/cuisine/time prefs)
- Shopping List screen
- Profile/Settings screen
- Notifications screen
- Splash/Onboarding screens
- Bottom navigation bar wiring
- image_picker wiring for recipe/profile photos
