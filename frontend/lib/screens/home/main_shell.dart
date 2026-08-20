import 'package:flutter/material.dart';
import '../../core/theme.dart';
import 'ingredients_screen.dart';
import '../search/search_filter_screen.dart';
import '../add_recipe/add_recipe_screen.dart';
import '../favorites/favorites_screen.dart';
import '../profile/profile_screen.dart';

/// Bottom-nav shell: Home | Search | Add Recipe | Favorites | Profile
class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int currentIndex = 0;

  final List<Widget> pages = const [
    IngredientsScreen(),
    SearchFilterScreen(),
    AddRecipeScreen(),
    FavoritesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: currentIndex, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (i) => setState(() => currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
            icon: CircleAvatar(backgroundColor: AppColors.primary, radius: 16, child: Icon(Icons.add, color: Colors.white, size: 18)),
            label: 'Add',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), activeIcon: Icon(Icons.favorite), label: 'Favorites'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
