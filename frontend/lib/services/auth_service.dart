import 'package:shared_preferences/shared_preferences.dart';
import '../core/api_client.dart';
import '../core/constants.dart';
import '../models/user_model.dart';

class AuthService {
  final ApiClient _api = ApiClient();

  Future<UserModel> signup(String name, String email, String password) async {
    final res = await _api.post(
      ApiConstants.signup,
      {'name': name, 'email': email, 'password': password},
      auth: false,
    );
    return _saveSessionAndReturnUser(res);
  }

  Future<UserModel> login(String email, String password) async {
    final res = await _api.post(
      ApiConstants.login,
      {'email': email, 'password': password},
      auth: false,
    );
    return _saveSessionAndReturnUser(res);
  }

  Future<void> forgotPassword(String email) async {
    await _api.post(ApiConstants.forgotPassword, {'email': email}, auth: false);
  }

  Future<UserModel> _saveSessionAndReturnUser(Map<String, dynamic> res) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', res['access_token']);
    return UserModel.fromJson(res['user']);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') != null;
  }

  /// Updates the logged-in user's profile (name, photo, dietary prefs).
  /// Any field left null is left unchanged on the backend.
  Future<UserModel> updateProfile({
    String? name,
    String? profilePhoto,
    List<String>? dietaryPrefs,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (profilePhoto != null) body['profile_photo'] = profilePhoto;
    if (dietaryPrefs != null) body['dietary_prefs'] = dietaryPrefs;

    final res = await _api.patch(ApiConstants.userMe, body);
    return UserModel.fromJson(res);
  }
}
