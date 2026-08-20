class UserModel {
  final String id;
  final String name;
  final String email;
  final String? profilePhoto;
  final List<String> dietaryPrefs;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.profilePhoto,
    this.dietaryPrefs = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        profilePhoto: json['profile_photo'],
        dietaryPrefs: List<String>.from(json['dietary_prefs'] ?? []),
      );
}
