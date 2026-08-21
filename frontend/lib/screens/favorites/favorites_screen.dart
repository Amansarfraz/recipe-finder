import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../services/recipe_service.dart';
import '../recipe/recipe_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});
  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final RecipeService _recipeService = RecipeService();
  List<dynamic> favorites = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final result = await _recipeService.getFavorites();
      setState(() => favorites = result);
    } catch (e) {
      setState(() => error = 'Could not load favorites: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _removeFavorite(String recipeId, int index) async {
    final removed = favorites[index];
    setState(() => favorites.removeAt(index));
    try {
      await _recipeService.removeFavorite(recipeId);
    } catch (e) {
      setState(() => favorites.insert(index, removed));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not remove favorite: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh), onPressed: _loadFavorites),
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
              : favorites.isEmpty
                  ? const Center(
                      child: Text(
                          'No favorites yet — tap the heart icon on any recipe to save it here.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textGrey)))
                  : RefreshIndicator(
                      onRefresh: _loadFavorites,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: favorites.length,
                        itemBuilder: (context, i) {
                          final r = favorites[i] as Map<String, dynamic>;
                          final title = r['title'] ?? 'Untitled Recipe';
                          final image = r['image'];
                          final cookTime = r['cook_time'];
                          final servings = r['servings'];
                          final recipeId = r['recipe_id'].toString();

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => RecipeDetailScreen(
                                    title: title,
                                    imageUrl: image,
                                    cookTime: cookTime ?? 30,
                                    servings: servings ?? 1,
                                  ),
                                ),
                              );
                            },
                            child: Container(
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
                              child: Stack(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                                top: Radius.circular(18)),
                                        child: image != null
                                            ? Image.network(image,
                                                height: 160,
                                                width: double.infinity,
                                                fit: BoxFit.cover,
                                                errorBuilder: (c, e, s) =>
                                                    Container(
                                                        height: 160,
                                                        color: AppColors
                                                            .primaryLight
                                                            .withOpacity(0.3)))
                                            : Container(
                                                height: 160,
                                                color: AppColors.primaryLight
                                                    .withOpacity(0.3),
                                                child: const Icon(
                                                    Icons.restaurant,
                                                    size: 40,
                                                    color: AppColors.primary)),
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
                                                    fontWeight:
                                                        FontWeight.w700)),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                if (cookTime != null)
                                                  _infoChip(Icons.access_time,
                                                      '$cookTime min'),
                                                if (cookTime != null)
                                                  const SizedBox(width: 8),
                                                if (servings != null)
                                                  _infoChip(Icons.people,
                                                      '$servings servings'),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Positioned(
                                    top: 12,
                                    right: 12,
                                    child: GestureDetector(
                                      onTap: () => _removeFavorite(recipeId, i),
                                      child: const CircleAvatar(
                                        backgroundColor: Colors.white,
                                        radius: 16,
                                        child: Icon(Icons.favorite,
                                            color: AppColors.primary, size: 18),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
          color: AppColors.primaryLight.withOpacity(0.4),
          borderRadius: BorderRadius.circular(10)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: AppColors.primaryDark),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(fontSize: 12, color: AppColors.textDark)),
      ]),
    );
  }
}
