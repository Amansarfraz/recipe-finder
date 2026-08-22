// import 'package:cached_network_image/cached_network_image.dart';

// import 'package:flutter/material.dart';
// import '../../core/theme.dart';
// import '../../core/image_helper.dart';
// import '../../services/recipe_service.dart';
// import '../recipe/recipe_detail_screen.dart';

// class SearchFilterScreen extends StatefulWidget {
//   const SearchFilterScreen({super.key});

//   @override
//   State<SearchFilterScreen> createState() => _SearchFilterScreenState();
// }

// class _SearchFilterScreenState extends State<SearchFilterScreen> {
//   final searchCtrl = TextEditingController();
//   final RecipeService _recipeService = RecipeService();

//   List<dynamic> recentSearches = [];
//   List<dynamic> results = [];
//   int totalResults = 0;
//   bool isLoading = false;
//   bool hasSearched = false;
//   String? error;

//   String cuisine = 'Any';
//   String time = 'Any';
//   String calories = 'Any';
//   String difficulty = 'Any';
//   String sortBy = 'popularity'; // "popularity" | "time"

//   final Set<String> _favoritedIds = {};
//   final Set<String> _pendingFavorite = {};

//   @override
//   void initState() {
//     super.initState();
//     _loadRecentSearches();
//   }

//   Future<void> _loadRecentSearches() async {
//     try {
//       final result = await _recipeService.getRecentSearches();
//       setState(() => recentSearches = result);
//     } catch (_) {
//       // best-effort — not logged in, or no history yet
//     }
//   }

//   int? _maxReadyTimeFor(String t) {
//     switch (t) {
//       case '15 min':
//         return 15;
//       case '30 min':
//         return 30;
//       case '60 min':
//         return 60;
//       default:
//         return null;
//     }
//   }

//   int? _maxCaloriesFor(String c) {
//     switch (c) {
//       case '<300':
//         return 300;
//       case '300-600':
//         return 600;
//       default:
//         return null; // "600+" and "Any" — no upper bound
//     }
//   }

//   Future<void> _runSearch(String query) async {
//     if (query.trim().isEmpty) return;
//     searchCtrl.text = query;
//     setState(() {
//       isLoading = true;
//       hasSearched = true;
//       error = null;
//     });

//     try {
//       final res = await _recipeService.searchByName(
//         query.trim(),
//         cuisine: cuisine,
//         maxReadyTime: _maxReadyTimeFor(time),
//         maxCalories: _maxCaloriesFor(calories),
//         sortBy: sortBy,
//       );
//       List<dynamic> fetched = res['results'] ?? [];

//       // Difficulty isn't a native Spoonacular filter, so it's applied
//       // client-side against the difficulty we compute per-recipe.
//       if (difficulty != 'Any') {
//         fetched = fetched.where((r) => r['difficulty'] == difficulty).toList();
//       }

//       setState(() {
//         results = fetched;
//         totalResults = res['total_results'] ?? fetched.length;
//       });

//       try {
//         await _recipeService.logRecentSearch(query.trim());
//         _loadRecentSearches();
//       } catch (_) {}
//     } catch (e) {
//       setState(() => error = 'Search failed: $e');
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   Future<void> _toggleFavorite(Map<String, dynamic> r) async {
//     final id = r['id'].toString();
//     if (_pendingFavorite.contains(id)) return;
//     setState(() => _pendingFavorite.add(id));

//     final isFav = _favoritedIds.contains(id);
//     try {
//       if (isFav) {
//         await _recipeService.removeFavorite(id);
//         setState(() => _favoritedIds.remove(id));
//       } else {
//         await _recipeService.addFavorite(
//           recipeId: id,
//           title: r['title'] ?? 'Untitled Recipe',
//           image: r['image'],
//           cookTime: r['readyInMinutes'],
//           servings: r['servings'],
//         );
//         setState(() => _favoritedIds.add(id));
//       }
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Could not update favorites: $e')),
//       );
//     } finally {
//       if (mounted) setState(() => _pendingFavorite.remove(id));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(
//         title: const Text('Recipe Find'),
//         leading: const BackButton(),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Search bar
//             Container(
//               decoration: BoxDecoration(
//                   color: Colors.white, borderRadius: BorderRadius.circular(14)),
//               child: TextField(
//                 controller: searchCtrl,
//                 textInputAction: TextInputAction.search,
//                 decoration: InputDecoration(
//                   hintText: 'Search recipes or ingredients...',
//                   prefixIcon:
//                       const Icon(Icons.search, color: AppColors.textGrey),
//                   border: InputBorder.none,
//                   contentPadding: const EdgeInsets.symmetric(vertical: 14),
//                   suffixIcon: Container(
//                     margin: const EdgeInsets.all(6),
//                     decoration: BoxDecoration(
//                         color: AppColors.primary,
//                         borderRadius: BorderRadius.circular(10)),
//                     child: IconButton(
//                       icon:
//                           const Icon(Icons.arrow_forward, color: Colors.white),
//                       onPressed: () => _runSearch(searchCtrl.text),
//                     ),
//                   ),
//                 ),
//                 onSubmitted: _runSearch,
//               ),
//             ),
//             const SizedBox(height: 20),

//             if (recentSearches.isNotEmpty) ...[
//               const Text('Recent Searches',
//                   style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
//               const SizedBox(height: 10),
//               Wrap(
//                 spacing: 8,
//                 runSpacing: 8,
//                 children: recentSearches.map((s) {
//                   final q = s['query'] as String;
//                   return GestureDetector(
//                     onTap: () => _runSearch(q),
//                     child: Chip(
//                       label: Text(q),
//                       backgroundColor: AppColors.primaryLight,
//                     ),
//                   );
//                 }).toList(),
//               ),
//               const SizedBox(height: 20),
//             ],

//             const Text('Filters',
//                 style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
//             const SizedBox(height: 10),
//             GridView.count(
//               crossAxisCount: 2,
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               crossAxisSpacing: 12,
//               mainAxisSpacing: 12,
//               childAspectRatio: 3,
//               children: [
//                 _filterDropdown(
//                     'Cuisine',
//                     cuisine,
//                     ['Any', 'Italian', 'Mexican', 'Indian', 'Chinese'],
//                     (v) => setState(() => cuisine = v!)),
//                 _filterDropdown(
//                     'Time',
//                     time,
//                     ['Any', '15 min', '30 min', '60 min'],
//                     (v) => setState(() => time = v!)),
//                 _filterDropdown(
//                     'Calories',
//                     calories,
//                     ['Any', '<300', '300-600', '600+'],
//                     (v) => setState(() => calories = v!)),
//                 _filterDropdown(
//                     'Difficulty',
//                     difficulty,
//                     ['Any', 'Easy', 'Medium', 'Hard'],
//                     (v) => setState(() => difficulty = v!)),
//               ],
//             ),
//             const SizedBox(height: 12),
//             SizedBox(
//               width: double.infinity,
//               child: OutlinedButton(
//                 onPressed: hasSearched && searchCtrl.text.trim().isNotEmpty
//                     ? () => _runSearch(searchCtrl.text)
//                     : null,
//                 child: const Text('Apply Filters'),
//               ),
//             ),
//             const SizedBox(height: 24),

//             if (hasSearched) ...[
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text('$totalResults recipes found',
//                       style: const TextStyle(color: AppColors.textGrey)),
//                   DropdownButton<String>(
//                     value: sortBy,
//                     underline: const SizedBox(),
//                     items: const [
//                       DropdownMenuItem(
//                           value: 'popularity',
//                           child: Text('Sort by: Popularity')),
//                       DropdownMenuItem(
//                           value: 'time', child: Text('Sort by: Time')),
//                     ],
//                     onChanged: (v) {
//                       setState(() => sortBy = v!);
//                       if (searchCtrl.text.trim().isNotEmpty)
//                         _runSearch(searchCtrl.text);
//                     },
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 12),
//             ],

//             if (isLoading)
//               const Padding(
//                 padding: EdgeInsets.symmetric(vertical: 40),
//                 child: Center(child: CircularProgressIndicator()),
//               )
//             else if (error != null)
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 24),
//                 child: Text(error!,
//                     style: const TextStyle(color: AppColors.danger)),
//               )
//             else if (hasSearched && results.isEmpty)
//               const Padding(
//                 padding: EdgeInsets.symmetric(vertical: 40),
//                 child: Center(
//                   child: Text(
//                       'No recipes found. Try a different search or filters.',
//                       style: TextStyle(color: AppColors.textGrey)),
//                 ),
//               )
//             else
//               ...results.map((r) => _resultCard(r)),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _resultCard(Map<String, dynamic> r) {
//     final id = r['id'].toString();
//     final title = r['title'] ?? 'Untitled Recipe';
//     final image = proxiedImageUrl(r['image']);
//     final readyIn = r['readyInMinutes'];
//     final difficultyLabel = r['difficulty'] ?? 'Medium';
//     final rating = r['rating'];
//     final isFav = _favoritedIds.contains(id);

//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) => RecipeDetailScreen(
//               title: title,
//               imageUrl: image,
//               cookTime: readyIn ?? 30,
//               difficulty: difficultyLabel,
//               servings: r['servings'] ?? 1,
//             ),
//           ),
//         );
//       },
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 16),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(18),
//           boxShadow: [
//             BoxShadow(
//                 color: Colors.black.withOpacity(0.06),
//                 blurRadius: 10,
//                 offset: const Offset(0, 4))
//           ],
//         ),
//         child: Stack(
//           children: [
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 ClipRRect(
//                   borderRadius:
//                       const BorderRadius.vertical(top: Radius.circular(18)),
//                   child: image != null
//                       ? Image.network(image,
//                           height: 160,
//                           width: double.infinity,
//                           fit: BoxFit.cover,
//                           errorBuilder: (c, e, s) => Container(
//                               height: 160,
//                               color: AppColors.primaryLight.withOpacity(0.3)))
//                       : Container(
//                           height: 160,
//                           color: AppColors.primaryLight.withOpacity(0.3),
//                           child: const Icon(Icons.restaurant,
//                               size: 40, color: AppColors.primary)),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(14),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(title,
//                           style: const TextStyle(
//                               fontSize: 16, fontWeight: FontWeight.w700)),
//                       const SizedBox(height: 6),
//                       Row(
//                         children: [
//                           if (rating != null) ...[
//                             const Icon(Icons.star,
//                                 color: Colors.amber, size: 14),
//                             Text(' $rating  ',
//                                 style: const TextStyle(
//                                     fontSize: 12, color: AppColors.textGrey)),
//                           ],
//                           if (readyIn != null)
//                             _infoChip(Icons.access_time, '$readyIn min'),
//                           const SizedBox(width: 8),
//                           _infoChip(Icons.bar_chart, difficultyLabel),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             Positioned(
//               top: 12,
//               right: 12,
//               child: GestureDetector(
//                 onTap: () => _toggleFavorite(r),
//                 child: CircleAvatar(
//                   backgroundColor: Colors.white,
//                   radius: 16,
//                   child: Icon(isFav ? Icons.favorite : Icons.favorite_border,
//                       color: AppColors.primary, size: 18),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _infoChip(IconData icon, String label) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//       decoration: BoxDecoration(
//           color: AppColors.primaryLight.withOpacity(0.4),
//           borderRadius: BorderRadius.circular(10)),
//       child: Row(mainAxisSize: MainAxisSize.min, children: [
//         Icon(icon, size: 13, color: AppColors.primaryDark),
//         const SizedBox(width: 4),
//         Text(label,
//             style: const TextStyle(fontSize: 12, color: AppColors.textDark)),
//       ]),
//     );
//   }

//   Widget _filterDropdown(String label, String value, List<String> options,
//       ValueChanged<String?> onChanged) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: AppColors.primaryLight),
//       ),
//       child: DropdownButtonHideUnderline(
//         child: DropdownButton<String>(
//           value: value,
//           isExpanded: true,
//           icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
//           items: options
//               .map((o) => DropdownMenuItem(
//                   value: o,
//                   child: Text('$label: $o', overflow: TextOverflow.ellipsis)))
//               .toList(),
//           onChanged: onChanged,
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/image_helper.dart';
import '../../services/recipe_service.dart';
import '../recipe/recipe_detail_screen.dart';

class SearchFilterScreen extends StatefulWidget {
  const SearchFilterScreen({super.key});

  @override
  State<SearchFilterScreen> createState() => _SearchFilterScreenState();
}

class _SearchFilterScreenState extends State<SearchFilterScreen> {
  final searchCtrl = TextEditingController();
  final RecipeService _recipeService = RecipeService();

  List<dynamic> recentSearches = [];
  List<dynamic> results = [];
  int totalResults = 0;
  bool isLoading = false;
  bool hasSearched = false;
  String? error;

  String cuisine = 'Any';
  String time = 'Any';
  String calories = 'Any';
  String difficulty = 'Any';
  String sortBy = 'popularity'; // "popularity" | "time"

  final Set<String> _favoritedIds = {};
  final Set<String> _pendingFavorite = {};

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
  }

  Future<void> _loadRecentSearches() async {
    try {
      final result = await _recipeService.getRecentSearches();
      setState(() => recentSearches = result);
    } catch (_) {
      // best-effort — not logged in, or no history yet
    }
  }

  int? _maxReadyTimeFor(String t) {
    switch (t) {
      case '15 min':
        return 15;
      case '30 min':
        return 30;
      case '60 min':
        return 60;
      default:
        return null;
    }
  }

  int? _maxCaloriesFor(String c) {
    switch (c) {
      case '<300':
        return 300;
      case '300-600':
        return 600;
      default:
        return null; // "600+" and "Any" — no upper bound
    }
  }

  Future<void> _runSearch(String query) async {
    if (query.trim().isEmpty) return;
    searchCtrl.text = query;
    setState(() {
      isLoading = true;
      hasSearched = true;
      error = null;
    });

    try {
      final res = await _recipeService.searchByName(
        query.trim(),
        cuisine: cuisine,
        maxReadyTime: _maxReadyTimeFor(time),
        maxCalories: _maxCaloriesFor(calories),
        sortBy: sortBy,
      );
      List<dynamic> fetched = res['results'] ?? [];

      // Difficulty isn't a native Spoonacular filter, so it's applied
      // client-side against the difficulty we compute per-recipe.
      if (difficulty != 'Any') {
        fetched = fetched.where((r) => r['difficulty'] == difficulty).toList();
      }

      setState(() {
        results = fetched;
        totalResults = res['total_results'] ?? fetched.length;
      });

      try {
        await _recipeService.logRecentSearch(query.trim());
        _loadRecentSearches();
      } catch (_) {}
    } catch (e) {
      setState(() => error = 'Search failed: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _toggleFavorite(Map<String, dynamic> r) async {
    final id = r['id'].toString();
    if (_pendingFavorite.contains(id)) return;
    setState(() => _pendingFavorite.add(id));

    final isFav = _favoritedIds.contains(id);
    try {
      if (isFav) {
        await _recipeService.removeFavorite(id);
        setState(() => _favoritedIds.remove(id));
      } else {
        await _recipeService.addFavorite(
          recipeId: id,
          title: r['title'] ?? 'Untitled Recipe',
          image: r['image'],
          cookTime: r['readyInMinutes'],
          servings: r['servings'],
        );
        setState(() => _favoritedIds.add(id));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update favorites: $e')),
      );
    } finally {
      if (mounted) setState(() => _pendingFavorite.remove(id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
            Container(
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(14)),
              child: TextField(
                controller: searchCtrl,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search recipes or ingredients...',
                  prefixIcon:
                      const Icon(Icons.search, color: AppColors.textGrey),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  suffixIcon: Container(
                    margin: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10)),
                    child: IconButton(
                      icon:
                          const Icon(Icons.arrow_forward, color: Colors.white),
                      onPressed: () => _runSearch(searchCtrl.text),
                    ),
                  ),
                ),
                onSubmitted: _runSearch,
              ),
            ),
            const SizedBox(height: 20),

            if (recentSearches.isNotEmpty) ...[
              const Text('Recent Searches',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: recentSearches.map((s) {
                  final q = s['query'] as String;
                  return GestureDetector(
                    onTap: () => _runSearch(q),
                    child: Chip(
                      label: Text(q),
                      backgroundColor: AppColors.primaryLight,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],

            const Text('Filters',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 3,
              children: [
                _filterDropdown(
                    'Cuisine',
                    cuisine,
                    ['Any', 'Italian', 'Mexican', 'Indian', 'Chinese'],
                    (v) => setState(() => cuisine = v!)),
                _filterDropdown(
                    'Time',
                    time,
                    ['Any', '15 min', '30 min', '60 min'],
                    (v) => setState(() => time = v!)),
                _filterDropdown(
                    'Calories',
                    calories,
                    ['Any', '<300', '300-600', '600+'],
                    (v) => setState(() => calories = v!)),
                _filterDropdown(
                    'Difficulty',
                    difficulty,
                    ['Any', 'Easy', 'Medium', 'Hard'],
                    (v) => setState(() => difficulty = v!)),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: hasSearched && searchCtrl.text.trim().isNotEmpty
                    ? () => _runSearch(searchCtrl.text)
                    : null,
                child: const Text('Apply Filters'),
              ),
            ),
            const SizedBox(height: 24),

            if (hasSearched) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('$totalResults recipes found',
                      style: const TextStyle(color: AppColors.textGrey)),
                  DropdownButton<String>(
                    value: sortBy,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(
                          value: 'popularity',
                          child: Text('Sort by: Popularity')),
                      DropdownMenuItem(
                          value: 'time', child: Text('Sort by: Time')),
                    ],
                    onChanged: (v) {
                      setState(() => sortBy = v!);
                      if (searchCtrl.text.trim().isNotEmpty)
                        _runSearch(searchCtrl.text);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],

            if (isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(error!,
                    style: const TextStyle(color: AppColors.danger)),
              )
            else if (hasSearched && results.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Text(
                      'No recipes found. Try a different search or filters.',
                      style: TextStyle(color: AppColors.textGrey)),
                ),
              )
            else
              ...results.map((r) => _resultCard(r)),
          ],
        ),
      ),
    );
  }

  Widget _resultCard(Map<String, dynamic> r) {
    final id = r['id'].toString();
    final title = r['title'] ?? 'Untitled Recipe';
    final image = proxiedImageUrl(r['image']);
    final readyIn = r['readyInMinutes'];
    final difficultyLabel = r['difficulty'] ?? 'Medium';
    final rating = r['rating'];
    final isFav = _favoritedIds.contains(id);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RecipeDetailScreen(
              title: title,
              imageUrl: image,
              cookTime: readyIn ?? 30,
              difficulty: difficultyLabel,
              servings: r['servings'] ?? 1,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(18)),
                  child: image != null
                      ? Image.network(image,
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(
                              height: 160,
                              color: AppColors.primaryLight.withOpacity(0.3)))
                      : Container(
                          height: 160,
                          color: AppColors.primaryLight.withOpacity(0.3),
                          child: const Icon(Icons.restaurant,
                              size: 40, color: AppColors.primary)),
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          if (rating != null) ...[
                            const Icon(Icons.star,
                                color: Colors.amber, size: 14),
                            Text(' $rating  ',
                                style: const TextStyle(
                                    fontSize: 12, color: AppColors.textGrey)),
                          ],
                          if (readyIn != null)
                            _infoChip(Icons.access_time, '$readyIn min'),
                          const SizedBox(width: 8),
                          _infoChip(Icons.bar_chart, difficultyLabel),
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
                onTap: () => _toggleFavorite(r),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 16,
                  child: Icon(isFav ? Icons.favorite : Icons.favorite_border,
                      color: AppColors.primary, size: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
          color: AppColors.primaryLight.withOpacity(0.4),
          borderRadius: BorderRadius.circular(10)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13, color: AppColors.primaryDark),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(fontSize: 12, color: AppColors.textDark)),
      ]),
    );
  }

  Widget _filterDropdown(String label, String value, List<String> options,
      ValueChanged<String?> onChanged) {
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
          items: options
              .map((o) => DropdownMenuItem(
                  value: o,
                  child: Text('$label: $o', overflow: TextOverflow.ellipsis)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
