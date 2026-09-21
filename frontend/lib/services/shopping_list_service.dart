import '../core/api_client.dart';
import '../core/constants.dart';

class ShoppingListService {
  final ApiClient _api = ApiClient();

  Future<List<dynamic>> getItems() async {
    final res = await _api.get(ApiConstants.shoppingList);
    return res['items'] ?? [];
  }

  Future<List<dynamic>> addItem(String name) async {
    final res =
        await _api.post('${ApiConstants.shoppingList}/items', {'name': name});
    return res['items'] ?? [];
  }

  Future<List<dynamic>> removeItem(String name) async {
    final res = await _api.delete('${ApiConstants.shoppingList}/items/$name');
    return res['items'] ?? [];
  }

  Future<List<dynamic>> toggleItem(String name) async {
    final res =
        await _api.patch('${ApiConstants.shoppingList}/$name/toggle', {});
    return res['items'] ?? [];
  }

  Future<void> clearList() async {
    await _api.delete(ApiConstants.shoppingList);
  }

  /// Adds every ingredient name in [ingredients] to the list in one go —
  /// used for external (Spoonacular) recipes that have no Mongo recipe id.
  Future<List<dynamic>> addIngredients(List<String> ingredients) async {
    final res =
        await _api.post('${ApiConstants.shoppingList}/add-ingredients', {
      'ingredients': ingredients,
    });
    return res['items'] ?? [];
  }
}
