import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  // Base API URL - adjust this to match your backend URL
  late final String _baseApiUrl;

  // Constructor to properly initialize the base URL
  AuthService() {
    // Remove trailing slash if present in API_URL
    String baseUrl =
        dotenv.env['API_URL'] ?? 'https://planma-app-production.up.railway.app';
    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }
    _baseApiUrl = baseUrl;
  }

  Future<Map<String, dynamic>?> signUp({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String password,
  }) async {
    final url = "$_baseApiUrl/users/";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "firstname": firstName,
          "lastname": lastName,
          "username": username,
          "email": email,
          "password": password
        }),
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final accessToken = responseData['access']; // Get the token
        if (accessToken != null) {
          // Store the token
          await storeToken(accessToken);
        }
        return responseData;
      } else {
        return {
          "error":
              jsonDecode(response.body)["detail"] ?? "Failed to create account"
        };
      }
    } catch (e) {
      print("error An error occurred. Please try again later:$e.");
      // Handle any errors that occurred during the request
      return {"error": "An error occurred. Please try again later:$e."};
    }
  }
}

Future<void> storeToken(String token) async {
  // Use a library like SharedPreferences to save the token
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  await sharedPreferences.setString('access', token);
}
