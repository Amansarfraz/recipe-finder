import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../services/recipe_service.dart';

class RecipeDetailScreen extends StatefulWidget {
  final String? recipeId; // Spoonacular id (or our Mongo id) — enables comments
  final String title;
  final String? imageUrl;
  final int cookTime;
  final String difficulty;
  final int servings;
  final List<Map<String, String>> ingredients;
  final List<String> instructions;
  final Map<String, String> nutrition;

  const RecipeDetailScreen({
    super.key,
    this.recipeId,
    this.title = 'Chicken Tomato Curry',
    this.imageUrl,
    this.cookTime = 50,
    this.difficulty = 'Medium',
    this.servings = 5,
    this.ingredients = const [
      {'name': 'Chicken', 'amount': '500g'},
      {'name': 'Tomato', 'amount': '4 large'},
      {'name': 'Onions', 'amount': '3 medium'},
      {'name': 'Spices', 'amount': '3 tbsp'},
      {'name': 'Cooking Oil', 'amount': '1 cup'},
      {'name': 'Garlic', 'amount': '4 cloves'},
      {'name': 'Curry Powder', 'amount': '3 tbsp'},
    ],
    this.instructions = const [
      'Heat oil in a large pan over medium heat.',
      'Add chopped onions and garlic, sauté until golden.',
      'Add chicken pieces and cook until browned.',
      'Stir in tomatoes, spices, and curry powder.',
      'Simmer covered for 30 minutes until chicken is tender.',
      'Serve hot with rice or naan.',
    ],
    this.nutrition = const {
      'Calories': '420 kcal',
      'Protein': '32g',
      'Carbs': '18g',
      'Fat': '22g'
    },
  });

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final RecipeService _recipeService = RecipeService();
  final commentCtrl = TextEditingController();

  List<dynamic> comments = [];
  bool isLoadingComments = false;
  bool isPostingComment = false;
  int selectedRating = 5;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    if (widget.recipeId != null) {
      _loadComments();
    }
  }

  Future<void> _loadComments() async {
    setState(() => isLoadingComments = true);
    try {
      final result = await _recipeService.getComments(widget.recipeId!);
      setState(() => comments = result);
    } catch (_) {
      // best-effort — leave list empty on failure
    } finally {
      if (mounted) setState(() => isLoadingComments = false);
    }
  }

  Future<void> _postComment() async {
    final text = commentCtrl.text.trim();
    if (text.isEmpty || widget.recipeId == null) return;

    setState(() => isPostingComment = true);
    try {
      await _recipeService.addComment(widget.recipeId!, text,
          rating: selectedRating);
      commentCtrl.clear();
      await _loadComments(); // refresh from server so it's never just a local echo
    } catch (e) {
      if (!mounted) return;
      _showSnack('Could not post your review: $e', isError: true);
    } finally {
      if (mounted) setState(() => isPostingComment = false);
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.danger : null,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: widget.imageUrl != null
                  ? Image.network(
                      widget.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _placeholderBackground(),
                    )
                  : _placeholderBackground(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.title,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _infoChip(Icons.access_time, '${widget.cookTime} min'),
                      const SizedBox(width: 10),
                      _infoChip(Icons.bar_chart, widget.difficulty),
                      const SizedBox(width: 10),
                      _infoChip(Icons.people, '${widget.servings} servings'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TabBar(
                    controller: _tabController,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.textGrey,
                    indicatorColor: AppColors.primary,
                    tabs: const [
                      Tab(text: 'Ingredients'),
                      Tab(text: 'Instructions'),
                      Tab(text: 'Nutrition')
                    ],
                  ),
                  SizedBox(
                    height: 320,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _ingredientsTab(),
                        _instructionsTab(),
                        _nutritionTab()
                      ],
                    ),
                  ),
                  const Divider(height: 40),
                  const Text('Comments & Reviews',
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  const SizedBox(height: 12),
                  if (widget.recipeId == null)
                    const Text(
                      'Reviews aren\'t available for this recipe yet.',
                      style: TextStyle(color: AppColors.textGrey, fontSize: 13),
                    )
                  else ...[
                    Row(
                      children: List.generate(5, (i) {
                        final starIndex = i + 1;
                        return IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            starIndex <= selectedRating
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 22,
                          ),
                          onPressed: () =>
                              setState(() => selectedRating = starIndex),
                        );
                      }),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: commentCtrl,
                            decoration: const InputDecoration(
                                hintText: 'Write a review...'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        isPostingComment
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2))
                            : IconButton(
                                icon: const Icon(Icons.send,
                                    color: AppColors.primary),
                                onPressed: _postComment,
                              ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (isLoadingComments)
                      const Center(
                          child: Padding(
                              padding: EdgeInsets.all(12),
                              child: CircularProgressIndicator()))
                    else if (comments.isEmpty)
                      const Text('No reviews yet — be the first!',
                          style: TextStyle(color: AppColors.textGrey))
                    else
                      ...comments.map((c) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(c['user_name'] ?? 'Anonymous',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13)),
                                      const Spacer(),
                                      Row(
                                        children: List.generate(
                                          5,
                                          (i) => Icon(
                                            i < (c['rating'] ?? 0)
                                                ? Icons.star
                                                : Icons.star_border,
                                            color: Colors.amber,
                                            size: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(c['text'] ?? ''),
                                ],
                              ),
                            ),
                          )),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholderBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(Icons.ramen_dining,
            color: Colors.white.withOpacity(0.6), size: 70),
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

  Widget _ingredientsTab() {
    return ListView(
      children: widget.ingredients
          .map((ing) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading:
                    const Icon(Icons.circle, size: 8, color: AppColors.primary),
                title: Text(ing['name'] ?? ''),
                trailing: Text(ing['amount'] ?? '',
                    style: const TextStyle(color: AppColors.textGrey)),
              ))
          .toList(),
    );
  }

  Widget _instructionsTab() {
    return ListView.builder(
      itemCount: widget.instructions.length,
      itemBuilder: (context, i) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
                radius: 12,
                backgroundColor: AppColors.primary,
                child: Text('${i + 1}',
                    style: const TextStyle(color: Colors.white, fontSize: 12))),
            const SizedBox(width: 10),
            Expanded(child: Text(widget.instructions[i])),
          ],
        ),
      ),
    );
  }

  Widget _nutritionTab() {
    return ListView(
      children: widget.nutrition.entries
          .map((e) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(e.key),
                trailing: Text(e.value,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              ))
          .toList(),
    );
  }
}
