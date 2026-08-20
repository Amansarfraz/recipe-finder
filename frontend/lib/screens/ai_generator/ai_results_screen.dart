import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../recipe/recipe_detail_screen.dart';

class AIResultsScreen extends StatelessWidget {
  final List<dynamic> recipes;
  const AIResultsScreen({super.key, required this.recipes});

  // Spoonacular doesn't return a difficulty label directly, so we derive
  // a simple Easy/Medium/Hard estimate from the cook time.
  String _difficultyFor(int? minutes) {
    if (minutes == null) return 'Medium';
    if (minutes <= 20) return 'Easy';
    if (minutes <= 45) return 'Medium';
    return 'Hard';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Generated Recipes')),
      body: recipes.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No recipes found for these ingredients. Try adding more ingredients or changing preferences.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textGrey),
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: recipes.length,
              itemBuilder: (context, i) {
                final r = recipes[i] as Map<String, dynamic>;
                final title = r['title'] ?? 'Untitled Recipe';
                final image = r['image'];
                final readyIn = r['readyInMinutes'] as int?;
                final servings = r['servings'];
                final difficulty = _difficultyFor(readyIn);

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RecipeDetailScreen(
                          title: title,
                          cookTime: readyIn ?? 30,
                          difficulty: difficulty,
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(18)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(title,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  _infoChip(Icons.access_time,
                                      '${readyIn ?? '--'} min'),
                                  const SizedBox(width: 10),
                                  _infoChip(Icons.bar_chart, difficulty),
                                  const SizedBox(width: 10),
                                  _infoChip(Icons.people,
                                      '${servings ?? '--'} servings'),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (image != null)
                          Image.network(image,
                              height: 160,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) =>
                                  const SizedBox.shrink()),
                        const SizedBox(height: 4),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
          color: Colors.white24, borderRadius: BorderRadius.circular(10)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13, color: Colors.white),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.white)),
      ]),
    );
  }
}
