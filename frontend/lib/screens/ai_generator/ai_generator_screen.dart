import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../core/theme.dart';
import '../../services/recipe_service.dart';
import 'ai_results_screen.dart';

class AIGeneratorScreen extends StatefulWidget {
  final List<String>? initialIngredients;
  const AIGeneratorScreen({super.key, this.initialIngredients});
  @override
  State<AIGeneratorScreen> createState() => _AIGeneratorScreenState();
}

class _AIGeneratorScreenState extends State<AIGeneratorScreen> {
  final ingredientCtrl = TextEditingController();
  late final List<String> ingredients;
  String dietType = 'Any';
  String cuisine = 'Any Cuisine';
  int maxCookTime = 30;
  bool isLoading = false;
  bool _isListening = false;

  final RecipeService _recipeService = RecipeService();
  final stt.SpeechToText _speech = stt.SpeechToText();

  @override
  void initState() {
    super.initState();
    ingredients = widget.initialIngredients != null
        ? List<String>.from(widget.initialIngredients!)
        : [];
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }

  void addIngredient() {
    final value = ingredientCtrl.text.trim();
    if (value.isEmpty) return;
    if (!ingredients.contains(value)) {
      setState(() => ingredients.add(value));
    }
    ingredientCtrl.clear();
  }

  Future<void> _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          setState(() => _isListening = false);
        }
      },
      onError: (error) {
        setState(() => _isListening = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Mic error: ${error.errorMsg}')),
        );
      },
    );
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (result) {
          setState(() => ingredientCtrl.text = result.recognizedWords);
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microphone permission not available')),
      );
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
    addIngredient();
  }

  Future<void> generateRecipes() async {
    if (ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one ingredient first')),
      );
      return;
    }
    setState(() => isLoading = true);
    try {
      final results = await _recipeService.searchByIngredients(
        ingredients,
        dietType: dietType == 'Any' ? 'Any' : dietType,
        cuisine: cuisine == 'Any Cuisine' ? 'Any' : cuisine,
        maxCookTime: maxCookTime,
      );
      final external = results['external_recipes'] as List<dynamic>? ?? [];
      if (!mounted) return;
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => AIResultsScreen(recipes: external)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate recipes: $e')),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDark),
        title: Row(
          children: [
            Image.asset(
              'assets/images/recipe_ai_icon.png',
              width: 26,
              height: 26,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.restaurant_menu,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 8),
            const Text('Recipe AI',
                style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark]),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.auto_awesome, color: Colors.white, size: 28),
                  SizedBox(height: 10),
                  Text('AI Recipe Generator',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('Transform your ingredients into delicious recipes.',
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Add Your Ingredients',
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.primaryLight),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: TextField(
                            controller: ingredientCtrl,
                            decoration: InputDecoration(
                              hintText: _isListening
                                  ? 'Listening...'
                                  : 'Enter ingredient...',
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isListening ? Icons.mic : Icons.mic_none,
                                  color: _isListening
                                      ? AppColors.primary
                                      : AppColors.textGrey,
                                ),
                                onPressed: _isListening
                                    ? _stopListening
                                    : _startListening,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                            ),
                            onSubmitted: (_) => addIngredient(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(14)),
                        child: IconButton(
                            icon: const Icon(Icons.add, color: Colors.white),
                            onPressed: addIngredient),
                      ),
                    ],
                  ),
                  if (ingredients.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ingredients
                          .map((i) => Chip(
                                label: Text(i),
                                backgroundColor: AppColors.primaryLight,
                                deleteIcon: const Icon(Icons.close, size: 16),
                                onDeleted: () =>
                                    setState(() => ingredients.remove(i)),
                              ))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Preferences',
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 14),
                  const Text('Diet Type',
                      style:
                          TextStyle(fontSize: 13, color: AppColors.textGrey)),
                  const SizedBox(height: 8),
                  Row(
                    children: ['Any', 'Vegetarian', 'Non-Vegetarian'].map((d) {
                      final selected = dietType == d;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: GestureDetector(
                            onTap: () => setState(() => dietType = d),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color:
                                    selected ? AppColors.primary : Colors.white,
                                border: Border.all(
                                    color: selected
                                        ? AppColors.primary
                                        : Colors.black12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(d,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: selected
                                          ? Colors.white
                                          : AppColors.textDark,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),
                  const Text('Cuisine',
                      style:
                          TextStyle(fontSize: 13, color: AppColors.textGrey)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black12),
                        borderRadius: BorderRadius.circular(12)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: cuisine,
                        isExpanded: true,
                        items: [
                          'Any Cuisine',
                          'Italian',
                          'Mexican',
                          'Indian',
                          'Chinese'
                        ]
                            .map((c) =>
                                DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: (v) => setState(() => cuisine = v!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text('Max Cooking Time',
                      style:
                          TextStyle(fontSize: 13, color: AppColors.textGrey)),
                  const SizedBox(height: 8),
                  Row(
                    children: [15, 30, 60].map((t) {
                      final selected = maxCookTime == t;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: GestureDetector(
                            onTap: () => setState(() => maxCookTime = t),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color:
                                    selected ? AppColors.primary : Colors.white,
                                border: Border.all(
                                    color: selected
                                        ? AppColors.primary
                                        : Colors.black12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text('$t min',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: selected
                                          ? Colors.white
                                          : AppColors.textDark,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                icon: isLoading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.auto_awesome, size: 18),
                label: Text(isLoading ? 'Generating...' : 'Generate Recipes'),
                onPressed: isLoading ? null : generateRecipes,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
