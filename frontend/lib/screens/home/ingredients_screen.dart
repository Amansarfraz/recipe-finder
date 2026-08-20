import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../core/theme.dart';
import '../../providers/recipe_provider.dart';
import '../ai_generator/ai_generator_screen.dart';

class IngredientsScreen extends StatefulWidget {
  const IngredientsScreen({super.key});
  @override
  State<IngredientsScreen> createState() => _IngredientsScreenState();
}

class _IngredientsScreenState extends State<IngredientsScreen> {
  final searchCtrl = TextEditingController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

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
          setState(() => searchCtrl.text = result.recognizedWords);
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
    if (searchCtrl.text.trim().isNotEmpty) {
      context.read<RecipeProvider>().addIngredient(searchCtrl.text.trim());
      searchCtrl.clear();
    }
  }

  Future<void> _editIngredient(RecipeProvider provider, String oldValue) async {
    final ctrl = TextEditingController(text: oldValue);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Ingredient'),
        content: TextField(controller: ctrl, autofocus: true),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty && result != oldValue) {
      final index = provider.selectedIngredients.indexOf(oldValue);
      if (index != -1) {
        provider.selectedIngredients[index] = result;
        provider.notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recipeProvider = context.watch<RecipeProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
              decoration: const BoxDecoration(color: AppColors.primary),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'What ingredients do you have?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Add ingredients to find recipes',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: TextField(
                        controller: searchCtrl,
                        decoration: InputDecoration(
                          hintText: _isListening
                              ? 'Listening...'
                              : 'Search ingredients',
                          prefixIcon: const Icon(Icons.search,
                              color: AppColors.textGrey),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isListening ? Icons.mic : Icons.mic_none,
                              color: _isListening
                                  ? AppColors.primary
                                  : AppColors.textGrey,
                            ),
                            onPressed:
                                _isListening ? _stopListening : _startListening,
                          ),
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onSubmitted: (v) {
                          if (v.trim().isEmpty) return;
                          recipeProvider.addIngredient(v.trim());
                          searchCtrl.clear();
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Selected Ingredients',
                            style: TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 15)),
                        Text(
                            '${recipeProvider.selectedIngredients.length} ingredients',
                            style: const TextStyle(
                                color: AppColors.textGrey, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: recipeProvider.selectedIngredients.isEmpty
                          ? const Center(
                              child: Text('No ingredients added yet',
                                  style: TextStyle(color: AppColors.textGrey)))
                          : ListView(
                              children: recipeProvider.selectedIngredients
                                  .map((ing) => Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 10),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryLight
                                              .withOpacity(0.55),
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(ing,
                                                  style: const TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color:
                                                          AppColors.textDark)),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.edit,
                                                  color: AppColors.primaryDark,
                                                  size: 20),
                                              onPressed: () => _editIngredient(
                                                  recipeProvider, ing),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete,
                                                  color: AppColors.danger,
                                                  size: 20),
                                              onPressed: () => recipeProvider
                                                  .removeIngredient(ing),
                                            ),
                                          ],
                                        ),
                                      ))
                                  .toList(),
                            ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: recipeProvider.selectedIngredients.isEmpty
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AIGeneratorScreen(
                                initialIngredients: List<String>.from(
                                    recipeProvider.selectedIngredients),
                              ),
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Find Recipes',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
