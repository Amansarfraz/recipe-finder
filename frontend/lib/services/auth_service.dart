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
}
