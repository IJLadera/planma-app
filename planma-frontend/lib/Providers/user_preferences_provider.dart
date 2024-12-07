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
  }

  // Fetch User Preferences
  Future<void> fetchUserPreferences(String userId) async {
    await _initAccessToken();
    final url = Uri.parse("${baseUrl}userpref/$userId/");

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
    required bool notificationEnabled,
    required String reminderOffsetTime,
    required String studentId,
    int? prefId,
  }) async {
    await _initAccessToken();
    final url = prefId != null
        ? Uri.parse("${baseUrl}updateuserpref/$prefId/")
        : Uri.parse("${baseUrl}createuserpref/");

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'usual_sleep_time': usualSleepTime,
          'usual_wake_time': usualWakeTime,
          'notification_enabled': notificationEnabled,
          'reminder_offset_time': reminderOffsetTime,
          'student_id': studentId,
        }),
      );

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
    final url = Uri.parse("${baseUrl}deleteuserpref/$prefId/");

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
