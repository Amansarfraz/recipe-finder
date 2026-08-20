class RecipeIngredient {
  final String name;
  final String? amount;
  RecipeIngredient({required this.name, this.amount});

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) =>
      RecipeIngredient(name: json['name'] ?? '', amount: json['amount']);

  Map<String, dynamic> toJson() => {'name': name, 'amount': amount};
}

class RecipeModel {
  final String? id;
  final String title;
  final String? photoUrl;
  final List<RecipeIngredient> ingredients;
  final List<String> steps;
  final String cuisine;
  final String dietType;
  final int? cookTime;
  final int? calories;
  final String difficulty;
  final int servings;
  final double ratingAvg;

  RecipeModel({
    this.id,
    required this.title,
    this.photoUrl,
    required this.ingredients,
    required this.steps,
    this.cuisine = 'Any',
    this.dietType = 'Any',
    this.cookTime,
    this.calories,
    this.difficulty = 'Medium',
    this.servings = 1,
    this.ratingAvg = 0.0,
  });

  factory RecipeModel.fromJson(Map<String, dynamic> json) => RecipeModel(
        id: json['id'],
        title: json['title'] ?? '',
        photoUrl: json['photo_url'] ?? json['image'],
        ingredients: (json['ingredients'] as List? ?? [])
            .map((e) => e is String ? RecipeIngredient(name: e) : RecipeIngredient.fromJson(e))
            .toList(),
        steps: List<String>.from(json['steps'] ?? []),
        cuisine: json['cuisine'] ?? 'Any',
        dietType: json['diet_type'] ?? 'Any',
        cookTime: json['cook_time'] ?? json['readyInMinutes'],
        calories: json['calories'],
        difficulty: json['difficulty'] ?? 'Medium',
        servings: json['servings'] ?? 1,
        ratingAvg: (json['rating_avg'] ?? 0).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'photo_url': photoUrl,
        'ingredients': ingredients.map((e) => e.toJson()).toList(),
        'steps': steps,
        'cuisine': cuisine,
        'diet_type': dietType,
        'cook_time': cookTime,
        'calories': calories,
        'difficulty': difficulty,
        'servings': servings,
      };
}
