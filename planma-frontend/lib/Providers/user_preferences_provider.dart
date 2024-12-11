import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserPreferencesProvider with ChangeNotifier {
  final String baseUrl = "http://127.0.0.1:8000/api/";
  String? _accessToken;

  // Store User Preferences
  Map<String, dynamic>? _userPreferences;

  Map<String, dynamic>? get userPreferences => _userPreferences;

  // Initialize access token
  Future<void> _initAccessToken() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _accessToken = sharedPreferences.getString("access");
    // If token is null or expired, navigate to login
    print("Access Token: $_accessToken");
    if (_accessToken == null) {
      throw Exception('Access token is missing or invalid');
    }
  }

  // Save access token after successful login
  Future<void> saveAccessToken(String token) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString("access", token);
    _accessToken = token; // Save token in memory
    notifyListeners();
  }

  // Fetch User Preferences
  Future<void> fetchUserPreferences() async {
    await _initAccessToken();
    final url = Uri.parse("${baseUrl}userprefs/");

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $_accessToken',
        },
      );

      if (response.statusCode == 200) {
        _userPreferences = json.decode(response.body);
        notifyListeners();
      } else {
        throw Exception('Failed to fetch user preferences');
      }
    } catch (error) {
      print("Error fetching user preferences: $error");
      throw Exception("Error: $error");
    }
  }

  // Create or Update User Preferences
  Future<void> saveUserPreferences({
    required String usualSleepTime,
    required String usualWakeTime,
    required String reminderOffsetTime,
    int? prefId,
  }) async {
    await _initAccessToken();
    final url = prefId != null
        ? Uri.parse("${baseUrl}userprefs/$prefId/") // Update URL
        : Uri.parse("${baseUrl}userprefs/"); // Create URL

    try {
      final response = await (prefId != null ? http.put : http.post)(
        url,
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'usual_sleep_time': usualSleepTime,
          'usual_wake_time': usualWakeTime,
          'reminder_offset_time': reminderOffsetTime,
        }),
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        _userPreferences = json.decode(response.body);
        notifyListeners();
      } else {
        throw Exception('Failed to save user preferences');
      }
    } catch (error) {
      print("Error saving user preferences: $error");
      throw Exception("Error: $error");
    }
  }

  // Delete User Preferences
  Future<void> deleteUserPreferences(int prefId) async {
    await _initAccessToken();
    final url = Uri.parse(
        "${baseUrl}userprefs/$prefId/"); // Adjust URL to reflect changes

    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $_accessToken',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        _userPreferences = null;
        notifyListeners();
      } else {
        throw Exception('Failed to delete user preferences');
      }
    } catch (error) {
      print("Error deleting user preferences: $error");
      throw Exception("Error: $error");
    }
  }
}
