import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthLogin {
  // Base API URL - adjust this to match your backend URL
  late final String _baseApiUrl;

  // Constructor to properly initialize the base URL
  AuthLogin() {
    // Remove trailing slash if present in API_URL
    String baseUrl = dotenv.env['API_URL'] ??
        'http://https://planma-app-production.up.railway';
    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }
    _baseApiUrl = baseUrl;
  }

  Future<Map<String, dynamic>?> logIn({
    required String email,
    required String password,
  }) async {
    final url = "$_baseApiUrl/auth/jwt/create/";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email":
              email, // Ensure you're sending the correct key (username instead of email if needed)
          "password": password
        }),
      );

      if (response.statusCode == 200) {
        jsonDecode(response.body);

        return jsonDecode(response.body); // Assuming JWT token is returned here
      } else {
        (response.body.toString());
        return {"error": jsonDecode(response.body) ?? "Failed to login"};
      }
    } catch (e) {
      return {"error": "An error occurred: ${e.toString()}"};
    }
  }
}
