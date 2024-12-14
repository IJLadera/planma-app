import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthLogout {
  String? _accessToken;
  String? get accessToken => _accessToken;

  final String baseUrl = "http://127.0.0.1:8000/api/";

  Future<void> logOut () async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    await sharedPreferences.remove("access");
    await sharedPreferences.remove("refresh");

    print("Logout successful");

    // _accessToken = sharedPreferences.getString("access");

    // final url = Uri.parse("${baseUrl}auth/token/logout/");

    // final response = await http.post(
    //   url,
    //   headers: {
    //     'Authorization': 'Bearer $_accessToken',
    //   },
    // );

    // if (response.statusCode == 204) {
    //   print("Logout successful");
    //   return jsonDecode(response.body);
    // } else {
    //   print("Logout failed");
    //   return {"error": "Failed to login"};
    // }
  }
}
    
