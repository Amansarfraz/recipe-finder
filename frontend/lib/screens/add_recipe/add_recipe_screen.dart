import 'package:flutter/material.dart';
import '../../core/theme.dart';

class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({super.key});
  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final titleCtrl = TextEditingController();
  final List<TextEditingController> ingredientCtrls = [TextEditingController()];
  final List<TextEditingController> stepCtrls = [TextEditingController()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Recipe')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Recipe Profile', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
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
                  const Icon(Icons.camera_alt, color: AppColors.primary, size: 32),
                  const SizedBox(height: 8),
                  const Text('Add a photo of your recipe', style: TextStyle(color: AppColors.textGrey)),
                  const Text('JPG, PNG, JPEG', style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {}, // TODO: image_picker integration
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8)),
                    child: const Text('Choose Photo'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('Recipe Title', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            const SizedBox(height: 8),
            TextField(controller: titleCtrl, decoration: const InputDecoration(hintText: 'Enter recipe name...')),
            const SizedBox(height: 20),

            _sectionHeader('Ingredients', () => setState(() => ingredientCtrls.add(TextEditingController()))),
            ...ingredientCtrls.map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TextField(controller: c, decoration: const InputDecoration(hintText: 'e.g. 2 cups flour')),
                )),
            const SizedBox(height: 12),

            _sectionHeader('Cooking Steps', () => setState(() => stepCtrls.add(TextEditingController()))),
            ...stepCtrls.asMap().entries.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TextField(
                    controller: entry.value,
                    maxLines: 2,
                    decoration: InputDecoration(hintText: 'Describe step ${entry.key + 1}...'),
                  ),
                )),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: wire up to RecipeService.createRecipe()
                },
                child: const Text('Publish Recipe'),
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
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        TextButton.icon(onPressed: onAdd, icon: const Icon(Icons.add, size: 18), label: const Text('Add')),
      ],
    );
  }
}
