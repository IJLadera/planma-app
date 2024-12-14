import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:planma_app/models/user_preferences_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPreferencesProvider with ChangeNotifier {
  String? _accessToken;
  List<UserPreferences> _userPreferences = [];

  List<UserPreferences> get userPreferences => _userPreferences;
  String? get accessToken => _accessToken;

  final String baseUrl = "http://127.0.0.1:8000/api/";

  // Fetch User Preferences
  Future<void> fetchUserPreferences() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _accessToken = sharedPreferences.getString("access");

    if (_accessToken == null) {
      throw Exception('Access token is missing or invalid');
    }

    final url = Uri.parse("${baseUrl}userprefs/");

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $_accessToken',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _userPreferences = data.map((item) => UserPreferences.fromJson(item)).toList();
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
    required TimeOfDay usualSleepTime,
    required TimeOfDay usualWakeTime,
    required String reminderOffsetTime,
    int? prefId,
  }) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _accessToken = sharedPreferences.getString("access");

    String formattedUsualSleepTime = _formatTimeOfDay(usualSleepTime);
    String formattedUsualWakeTime = _formatTimeOfDay(usualWakeTime);

    if (_accessToken == null) {
      throw Exception('Access token is missing or invalid');
    }

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
          'usual_sleep_time': formattedUsualSleepTime,
          'usual_wake_time': formattedUsualWakeTime,
          'reminder_offset_time': reminderOffsetTime,
        }),
      );

      print("Preferences saved: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final newUserPreferences = UserPreferences.fromJson(json.decode(response.body));
        _userPreferences.add(newUserPreferences);
      } else {
        throw Exception('Failed to save user preferences');
      }
    } catch (error) {
      print("Error saving user preferences: $error");
      throw Exception("Error: $error");
    }
  }

  // Utility method to format TimeOfDay to HH:mm:ss
  String _formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dateTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    return DateFormat('HH:mm:ss').format(dateTime);
  }

  Duration parseReminderOffset(String reminderOffset) {
    final regex = RegExp(r"(\d+)\s*h\s*:\s*(\d+)\s*m");
    final match = regex.firstMatch(reminderOffset);

    if (match != null) {
      final int hours = int.parse(match.group(1)!);
      final int minutes = int.parse(match.group(2)!);

      return Duration(hours: hours, minutes: minutes);
    } else {
      throw FormatException("Invalid reminder offset format: $reminderOffset");
    }
  }
}
