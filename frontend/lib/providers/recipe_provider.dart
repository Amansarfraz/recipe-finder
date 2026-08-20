import 'package:flutter/foundation.dart';
import '../models/recipe_model.dart';
import '../services/recipe_service.dart';

class RecipeProvider extends ChangeNotifier {
  final RecipeService _recipeService = RecipeService();

  final List<String> selectedIngredients = [];
  List<dynamic> userRecipeResults = [];
  List<dynamic> externalRecipeResults = [];
  bool isLoading = false;
  String? error;

  void addIngredient(String ingredient) {
    if (ingredient.trim().isEmpty) return;
    if (!selectedIngredients.contains(ingredient)) {
      selectedIngredients.add(ingredient);
      notifyListeners();
    }
  }

  void removeIngredient(String ingredient) {
    selectedIngredients.remove(ingredient);
    notifyListeners();
  }

  Future<void> findRecipes({String dietType = 'Any', String cuisine = 'Any', int? maxCookTime}) async {
    if (selectedIngredients.isEmpty) return;
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final res = await _recipeService.searchByIngredients(
        selectedIngredients,
        dietType: dietType,
        cuisine: cuisine,
        maxCookTime: maxCookTime,
      );
      userRecipeResults = res['user_recipes'] ?? [];
      externalRecipeResults = res['external_recipes'] ?? [];
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
