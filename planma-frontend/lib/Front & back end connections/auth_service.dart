import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = "http://127.0.0.1:8000/api/";

  Future<Map<String, dynamic>?> signUp({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String password,
  }) async {
    final url = "${baseUrl}users/";

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
