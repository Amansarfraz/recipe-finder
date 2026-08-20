class ApiConstants {
  // Change to your machine's LAN IP when testing on a real device,
  // or 10.0.2.2 for Android emulator (maps to host's localhost).
  static const String baseUrl = "http://127.0.0.1:8000";

  static const String signup = "/auth/signup";
  static const String login = "/auth/login";
  static const String forgotPassword = "/auth/forgot-password";
  static const String recipeSearch = "/recipes/search";
  static const String aiGenerate = "/recipes/ai-generate";
  static const String recipes = "/recipes";
  static const String favorites = "/favorites";
  static const String shoppingList = "/shopping-list";
  static const String userMe = "/users/me";
  static const String notifications = "/notifications";
  static const String recentSearches = "/recent-searches";
}
