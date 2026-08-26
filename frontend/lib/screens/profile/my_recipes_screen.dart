import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../services/recipe_service.dart';

class MyRecipesScreen extends StatefulWidget {
  const MyRecipesScreen({super.key});
  @override
  State<MyRecipesScreen> createState() => _MyRecipesScreenState();
}

class _MyRecipesScreenState extends State<MyRecipesScreen> {
  final RecipeService _recipeService = RecipeService();
  List<dynamic> recipes = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final result = await _recipeService.getMyRecipes();
      setState(() => recipes = result);
    } catch (e) {
      setState(() => error = 'Could not load your recipes: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Recipes'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load)
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.textGrey)),
                  ),
                )
              : recipes.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'You haven\'t published any recipes yet.\nUse the Add tab to create one!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textGrey),
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: recipes.length,
                        itemBuilder: (context, i) {
                          final r = recipes[i] as Map<String, dynamic>;
                          final title = r['title'] ?? 'Untitled Recipe';
                          final photoUrl = r['photo_url'] as String?;
                          final ingredients = (r['ingredients'] as List? ?? []);
                          final steps = (r['steps'] as List? ?? []);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withOpacity(0.06),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4))
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(18)),
                                  child:
                                      (photoUrl != null && photoUrl.isNotEmpty)
                                          ? Image.network(photoUrl,
                                              height: 160,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                              errorBuilder: (c, e, s) =>
                                                  _placeholder())
                                          : _placeholder(),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(title,
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700)),
                                      const SizedBox(height: 6),
                                      Text(
                                        '${ingredients.length} ingredients · ${steps.length} steps',
                                        style: const TextStyle(
                                            color: AppColors.textGrey,
                                            fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
    );
  }

  Widget _placeholder() {
    return Container(
      height: 160,
      color: AppColors.primaryLight.withOpacity(0.3),
      child: const Icon(Icons.restaurant, size: 40, color: AppColors.primary),
    );
  }
}
