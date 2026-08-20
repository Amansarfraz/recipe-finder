import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/recipe_provider.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/main_shell.dart';
import 'screens/search/search_filter_screen.dart';
import 'screens/add_recipe/add_recipe_screen.dart';
import 'screens/recipe/recipe_detail_screen.dart';
import 'screens/ai_generator/ai_generator_screen.dart';
import 'screens/shopping_list/shopping_list_screen.dart';
import 'screens/profile/notifications_screen.dart';

void main() {
  runApp(const RecipeFinderApp());
}

class RecipeFinderApp extends StatelessWidget {
  const RecipeFinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => RecipeProvider()),
      ],
      child: MaterialApp(
        title: 'Smart Recipe Finder',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        initialRoute: '/splash',
        routes: {
          '/splash': (_) => const SplashScreen(),
          '/signup': (_) => const SignupScreen(),
          '/login': (_) => const LoginScreen(),
          '/ingredients': (_) => const MainShell(),   // lands on bottom-nav Home tab
          '/home': (_) => const MainShell(),
          '/results': (_) => const SearchFilterScreen(),
          '/add-recipe': (_) => const AddRecipeScreen(),
          '/recipe-detail': (_) => const RecipeDetailScreen(),
          '/ai-generator': (_) => const AIGeneratorScreen(),
          '/shopping-list': (_) => const ShoppingListScreen(),
          '/notifications': (_) => const NotificationsScreen(),
        },
      ),
    );
  }
}
