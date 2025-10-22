import 'dart:convert';
import 'package:http/http.dart';
import 'package:planma_app/config/network/api_client.dart';
import 'package:planma_app/features/authentication/data/models/auth_user_model.dart';
import 'package:planma_app/features/authentication/domain/entities/auth_user.dart';
import 'package:planma_app/features/authentication/domain/repositories/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiAuthRepository implements AuthRepository {
  final ApiClient _apiClient = ApiClient();

  // Checks token and store the user
  @override
  Future<void> checkAndStoreCurrentUser() async {
    // Open Shared Preferences
    SharedPreferences preferences = await SharedPreferences.getInstance();

    // Get access token
    final accessToken = preferences.getString('access');
    if (accessToken == null) return;

    try {
      final Response response =
          await _apiClient.get("djoser/users/me/", headers: {
        'Authorization': 'Bearer $accessToken',
      });

      // Save user data to shared preferences
      await preferences.setString('user_data', jsonEncode(response.body));
    } catch (e) {
      throw Exception('Failed fetching the current user: $e');
    }
  }

  @override
  Future<AuthUser?> loginWithEmailAndPassword(
      String email, String password) async {
    try {
      // Attempt Sign In email and password
      Response response = await _apiClient.post("auth/jwt/create/", {
        "email": email,
        "password": password,
      });

      // Create user
      AuthUserModel user = AuthUserModel.fromJson(response.body as Map<String, dynamic>);

      // Save it ot shared preferences
      SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.setString('access', user.access);
      await preferences.setString('refresh', user.refresh);
      await preferences.setString('student_id', user.studentId);

      // Check and store the current user
      await checkAndStoreCurrentUser();

      // Return user
      return user;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }
}
