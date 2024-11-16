import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl = "http://127.0.0.1:8000/accounts/";

  Future<Map<String, dynamic>?> signUp({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String password,
  }) async {
    final url = "${baseUrl}djoser/users/";
    return null;

    //   try {
    //     final response = await http.post(
    //       Uri.parse(url),
    //       headers: {"Content-Type": "application/json"},
    //       body: jsonEncode({
    //         "firstname": firstName,
    //         "lastname": lastName,
    //         "username": username,
    //         "email": email,
    //         "password": password
    //       }),

    //     );

    //     if (response.statusCode == 201) {
    //       // Successfully created account
    //       return jsonDecode(response.body);
    //     } else {
    //       // Handle error response
    //       return {
    //         "error": jsonDecode(response.body)["detail"] ??
    //             "Failed to create account"
    //       };
    //     }
    //   } catch (e) {
    //     print("error An error occurred. Please try again later:$e.");
    //     // Handle any errors that occurred during the request
    //     return {"error": "An error occurred. Please try again later:$e."};
    //   }
  }
}
