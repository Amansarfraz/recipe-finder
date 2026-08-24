import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/recipe_model.dart';
import '../../services/recipe_service.dart';

class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({super.key});
  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _IngredientRow {
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController amountCtrl = TextEditingController();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final titleCtrl = TextEditingController();
  final cuisineCtrl = TextEditingController();
  final cookTimeCtrl = TextEditingController();
  final servingsCtrl = TextEditingController();
  final RecipeService _recipeService = RecipeService();

  final List<_IngredientRow> ingredientRows = [_IngredientRow()];
  final List<TextEditingController> stepCtrls = [TextEditingController()];

  bool isPublishing = false;

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.danger : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
      ),
    );
  }

  Future<void> _publish() async {
    final title = titleCtrl.text.trim();
    if (title.isEmpty) {
      _showSnack('Please enter a recipe title', isError: true);
      return;
    }

    final ingredients = ingredientRows
        .where((row) => row.nameCtrl.text.trim().isNotEmpty)
        .map((row) => RecipeIngredient(
              name: row.nameCtrl.text.trim(),
              amount: row.amountCtrl.text.trim().isEmpty
                  ? null
                  : row.amountCtrl.text.trim(),
            ))
        .toList();

    if (ingredients.isEmpty) {
      _showSnack('Please add at least one ingredient', isError: true);
      return;
    }

    final steps =
        stepCtrls.map((c) => c.text.trim()).where((s) => s.isNotEmpty).toList();
    if (steps.isEmpty) {
      _showSnack('Please add at least one cooking step', isError: true);
      return;
    }

    setState(() => isPublishing = true);
    try {
      final recipe = RecipeModel(
        title: title,
        ingredients: ingredients,
        steps: steps,
        cuisine:
            cuisineCtrl.text.trim().isEmpty ? 'Any' : cuisineCtrl.text.trim(),
        cookTime: int.tryParse(cookTimeCtrl.text.trim()),
        servings: int.tryParse(servingsCtrl.text.trim()) ?? 1,
      );
      await _recipeService.createRecipe(recipe);
      if (!mounted) return;
      _showSnack('Recipe published!');
      _resetForm();
    } catch (e) {
      if (!mounted) return;
      _showSnack('Could not publish recipe: $e', isError: true);
    } finally {
      if (mounted) setState(() => isPublishing = false);
    }
  }

  void _resetForm() {
    setState(() {
      titleCtrl.clear();
      cuisineCtrl.clear();
      cookTimeCtrl.clear();
      servingsCtrl.clear();
      ingredientRows
        ..clear()
        ..add(_IngredientRow());
      stepCtrls
        ..clear()
        ..add(TextEditingController());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Recipe')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Recipe Profile',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            const SizedBox(height: 10),
            Container(
              height: 130,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primaryLight),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.camera_alt,
                      color: AppColors.primary, size: 32),
                  const SizedBox(height: 8),
                  const Text('Photo upload coming soon',
                      style: TextStyle(color: AppColors.textGrey)),
                  const Text('You can still publish your recipe without one',
                      style:
                          TextStyle(color: AppColors.textGrey, fontSize: 11)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('Recipe Title',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            const SizedBox(height: 8),
            TextField(
                controller: titleCtrl,
                decoration:
                    const InputDecoration(hintText: 'Enter recipe name...')),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Cuisine (optional)',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(height: 6),
                      TextField(
                          controller: cuisineCtrl,
                          decoration:
                              const InputDecoration(hintText: 'e.g. Italian')),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Cook Time (min)',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: cookTimeCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: 'e.g. 30'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Servings',
                    style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 6),
                TextField(
                  controller: servingsCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: 'e.g. 4'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _sectionHeader('Ingredients',
                () => setState(() => ingredientRows.add(_IngredientRow()))),
            const SizedBox(height: 8),
            ...ingredientRows.asMap().entries.map((entry) {
              final row = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextField(
                          controller: row.nameCtrl,
                          decoration: const InputDecoration(
                              hintText: 'Ingredient name')),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: TextField(
                          controller: row.amountCtrl,
                          decoration:
                              const InputDecoration(hintText: 'e.g. 2 cups')),
                    ),
                    if (ingredientRows.length > 1)
                      IconButton(
                        icon: const Icon(Icons.close,
                            color: AppColors.danger, size: 20),
                        onPressed: () =>
                            setState(() => ingredientRows.remove(row)),
                      ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 12),
            _sectionHeader('Cooking Steps',
                () => setState(() => stepCtrls.add(TextEditingController()))),
            const SizedBox(height: 8),
            ...stepCtrls.asMap().entries.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: entry.value,
                          maxLines: 2,
                          decoration: InputDecoration(
                              hintText: 'Describe step ${entry.key + 1}...'),
                        ),
                      ),
                      if (stepCtrls.length > 1)
                        IconButton(
                          icon: const Icon(Icons.close,
                              color: AppColors.danger, size: 20),
                          onPressed: () =>
                              setState(() => stepCtrls.remove(entry.value)),
                        ),
                    ],
                  ),
                )),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isPublishing ? null : _publish,
                child: isPublishing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Publish Recipe'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, VoidCallback onAdd) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        TextButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add')),
      ],
    );
  }
}
