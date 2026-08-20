import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/recipe_card.dart';

/// Re-themed version of the "RecipeFind" search/filter screen from the
/// Figma draft — layout kept the same, colors switched to match the
/// app-wide orange "Smart Recipe Finder" brand instead of the original blue.
class SearchFilterScreen extends StatefulWidget {
  const SearchFilterScreen({super.key});

  @override
  State<SearchFilterScreen> createState() => _SearchFilterScreenState();
}

class _SearchFilterScreenState extends State<SearchFilterScreen> {
  final List<String> recentSearches = ['Pasta', 'Chicken', 'Vegetarian'];
  String cuisine = 'Any';
  String time = 'Any';
  String calories = 'Any';
  String difficulty = 'Any';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Find'),
        leading: const BackButton(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search recipes or ingredients...',
                prefixIcon: const Icon(Icons.search, color: AppColors.textGrey),
                suffixIcon: Container(
                  margin: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.arrow_forward, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Recent searches
            const Text('Recent Searches', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: recentSearches
                  .map((s) => Chip(
                        label: Text(s),
                        backgroundColor: AppColors.primaryLight,
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20),

            // Filters
            const Text('Filters', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 3,
              children: [
                _filterDropdown('Cuisine', cuisine, ['Any', 'Italian', 'Mexican', 'Indian', 'Chinese'],
                    (v) => setState(() => cuisine = v!)),
                _filterDropdown('Time', time, ['Any', '15 min', '30 min', '60 min'],
                    (v) => setState(() => time = v!)),
                _filterDropdown('Calories', calories, ['Any', '<300', '300-600', '600+'],
                    (v) => setState(() => calories = v!)),
                _filterDropdown('Difficulty', difficulty, ['Any', 'Easy', 'Medium', 'Hard'],
                    (v) => setState(() => difficulty = v!)),
              ],
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('1,247 recipes found', style: TextStyle(color: AppColors.textGrey)),
                TextButton(onPressed: () {}, child: const Text('Sort by ▾')),
              ],
            ),
            const SizedBox(height: 12),

            // Results list (placeholder cards — wire up to RecipeProvider results)
            RecipeCard(title: 'Creamy Spaghetti Carbonara', cookTime: 25, rating: 4.8, tag: 'Easy'),
            RecipeCard(title: 'Rainbow Quinoa Buddha Bowl', cookTime: 15, rating: 4.6, tag: 'Easy'),
            RecipeCard(title: 'Herb-Crusted Grilled Chicken', cookTime: 30, rating: 4.7, tag: 'Medium'),
          ],
        ),
      ),
    );
  }

  Widget _filterDropdown(String label, String value, List<String> options, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryLight),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
          items: options.map((o) => DropdownMenuItem(value: o, child: Text('$label: $o', overflow: TextOverflow.ellipsis))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
