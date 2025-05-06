import 'dart:convert';

import 'package:http/http.dart';
import 'package:planma/config/http.dart';
import 'package:planma/features/authentication/domain/entities/app_user.dart';
import 'package:planma/features/authentication/domain/repositories/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiAuthRepository implements AuthRepository {
  final ApiClient _apiClient = ApiClient();

  // Check if authenticated
  @override
  Future<bool> checkAuth() async {
    // Get user
    final user = await getCurrentUser();

    return user != null ? true : false;
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    try {
      // Open Shared Preferences
      SharedPreferences preferences = await SharedPreferences.getInstance();

      final user = preferences.getString('user_data');

      AppUser appUser = AppUser.fromJson(user as Map<String, dynamic>);

      // Return user
      return appUser;
    } catch (e) {
      throw Exception('Error fetching current user: $e');
    }
  }

  @override
  Future<AppUser?> loginWithEmailAndPassword(
      String email, String password) async {
    try {
      // Attempt Sign In email and password
      Response response = await _apiClient.post("auth/jwt/create/", {
        "email": email,
        "password": password,
      });

      // Create user
      AppUser user = AppUser.fromJson(response.body as Map<String, dynamic>);

      // Save user data to shared preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', jsonEncode(user));

      // Return user
      return user;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }
}
