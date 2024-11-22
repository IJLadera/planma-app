import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserProfileProvider with ChangeNotifier {
  String? _firstName;
  String? _lastName;
  String? _username;
  String? _accessToken;

  String? get firstName => _firstName;
  String? get lastName => _lastName;
  String? get username => _username;
  String? get accessToken => _accessToken;

  Future<void> init() async {
    await fetchUserProfile();
    notifyListeners();
  }

  // void updateToken (String token) {
  //   _token = token;
  //   notifyListeners();
  // }

  final String baseUrl = "http://127.0.0.1:8000/api/";

  //Fetch user profile
  Future<void> fetchUserProfile() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _accessToken = sharedPreferences.getString("access");
    final url = Uri.parse("${baseUrl}djoser/users/me/");
    
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $_accessToken',
        },
      );
      

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data.toString());
        _firstName = data['firstname'];
        _lastName = data['lastname'];
        _username = data['username'];
        notifyListeners();
      } else {
        throw Exception('Failed to fetch profile. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      rethrow;
    }
  }

  //Update user profile
  Future<void> updateUserProfile(String firstName, String lastName, String username) async {
    final url = Uri.parse("${baseUrl}djoser/users/me/");

    try {
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'firstname': firstName,
          'lastname': lastName,
          'username': username,
        }),
      );

      if (response.statusCode == 200) {
        _firstName = firstName;
        _lastName = lastName;
        _username = username;
        notifyListeners();
      } else {
        throw Exception('Failed to fetch profile. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      rethrow;
    }
  }
}
