import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthLogin {
  final String baseUrl = "http://127.0.0.1:8000/api/";

  Future<Map<String, dynamic>?> logIn({
    required String email,
    required String password,
  }) async {
    final url = "${baseUrl}auth/jwt/create/";

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
