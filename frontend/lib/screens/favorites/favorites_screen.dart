import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/recipe_card.dart';
import '../recipe/recipe_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});
  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final List<String> tabs = ['All', 'Breakfast', 'Dinner', 'Desserts'];
  String selectedTab = 'All';

  // Placeholder data — replace with RecipeService.getFavorites() results
  final List<Map<String, dynamic>> favorites = [
    {'title': 'Creamy Sausage Pasta', 'cookTime': 30, 'rating': 4.9, 'tag': 'Dinner'},
    {'title': 'Cheese Pizza', 'cookTime': 30, 'rating': 5.0, 'tag': 'Dinner'},
    {'title': 'Croque Madame', 'cookTime': 20, 'rating': 6.3, 'tag': 'Breakfast'},
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = selectedTab == 'All'
        ? favorites
        : favorites.where((f) => f['tag'] == selectedTab).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: tabs.map((t) {
                  final selected = t == selectedTab;
                  final count = t == 'All' ? favorites.length : favorites.where((f) => f['tag'] == t).length;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text('$t ($count)'),
                      selected: selected,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(color: selected ? Colors.white : AppColors.textDark),
                      backgroundColor: Colors.white,
                      onSelected: (_) => setState(() => selectedTab = t),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('No favorites yet', style: TextStyle(color: AppColors.textGrey)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filtered.length,
                    itemBuilder: (context, i) {
                      final r = filtered[i];
                      return RecipeCard(
                        title: r['title'],
                        cookTime: r['cookTime'],
                        rating: r['rating'],
                        tag: r['tag'],
                        isFavorite: true,
                        onFavoriteToggle: () => setState(() => favorites.removeAt(i)),
                        onTap: () => Navigator.push(
                            context, MaterialPageRoute(builder: (_) => RecipeDetailScreen(title: r['title']))),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
