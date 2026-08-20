import '../core/api_client.dart';
import '../core/constants.dart';
import '../models/recipe_model.dart';

class RecipeService {
  final ApiClient _api = ApiClient();

  Future<Map<String, dynamic>> searchByIngredients(
    List<String> ingredients, {
    String dietType = 'Any',
    String cuisine = 'Any',
    int? maxCookTime,
  }) async {
    final query = {
      'ingredients': ingredients.join(','),
      'diet_type': dietType,
      'cuisine': cuisine,
      if (maxCookTime != null) 'max_cook_time': maxCookTime.toString(),
    };
    final qs = Uri(queryParameters: query).query;
    return await _api.get('${ApiConstants.recipeSearch}?$qs');
  }

  Future<RecipeModel> getRecipe(String id) async {
    final res = await _api.get('${ApiConstants.recipes}/$id');
    return RecipeModel.fromJson(res);
  }

  Future<RecipeModel> createRecipe(RecipeModel recipe) async {
    final res = await _api.post(ApiConstants.recipes, recipe.toJson());
    return RecipeModel.fromJson(res);
  }

  // ---- Favorites ----

  Future<List<dynamic>> getFavorites() async {
    return await _api.get(ApiConstants.favorites);
  }

  Future<void> addFavorite({
    required String recipeId,
    required String title,
    String? image,
    int? cookTime,
    int? servings,
    String source = 'spoonacular',
  }) async {
    await _api.post(ApiConstants.favorites, {
      'recipe_id': recipeId,
      'title': title,
      'image': image,
      'cook_time': cookTime,
      'servings': servings,
      'source': source,
    });
  }

  Future<void> removeFavorite(String recipeId) async {
    await _api.delete('${ApiConstants.favorites}/$recipeId');
  }

  // ---- Recent Searches ----

  Future<List<dynamic>> getRecentSearches() async {
    return await _api.get(ApiConstants.recentSearches);
  }

  Future<void> logRecentSearch(String query) async {
    await _api.post(ApiConstants.recentSearches, {'query': query});
  }
}
