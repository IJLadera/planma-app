import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:planma_app/models/user_preferences_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPreferencesProvider with ChangeNotifier {
  String? _accessToken;
  List<UserPreferences> _userPreferences = [];

  List<UserPreferences> get userPreferences => _userPreferences;
  String? get accessToken => _accessToken;

  // Base API URL
  late final String _baseApiUrl;

  // Constructor to properly initialize the base URL
  UserPreferencesProvider() {
    // Remove trailing slash if present in API_URL
    String baseUrl =
        dotenv.env['API_URL'] ?? 'https://planma-app-production.up.railway.app';
    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }
    _baseApiUrl = '$baseUrl/api';
  }

  // Fetch User Preferences
  Future<void> fetchUserPreferences() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _accessToken = sharedPreferences.getString("access");

    if (_accessToken == null || _accessToken!.isEmpty) {
      return;
    }

    final url = Uri.parse("$_baseApiUrl/userprefs/");

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $_accessToken',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _userPreferences =
            data.map((item) => UserPreferences.fromJson(item)).toList();
        notifyListeners();
      } else {
        throw Exception('Failed to fetch user preferences');
      }
    } catch (error) {
      print("Error fetching user preferences: $error");
      throw Exception("Error: $error");
    }
  }

  // Create User Preferences
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

    final url = Uri.parse("$_baseApiUrl/userprefs/");
    try {
      final response = await http.post(
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
        final newUserPreferences =
            UserPreferences.fromJson(json.decode(response.body));
        _userPreferences.add(newUserPreferences);
        notifyListeners();
      } else {
        throw Exception('Failed to save user preferences');
      }
    } catch (error) {
      print("Error saving user preferences: $error");
      throw Exception("Error: $error");
    }
  }

  // Save Sleep and Wake Times
  Future<void> saveSleepWakeTimes({
    required TimeOfDay usualSleepTime,
    required TimeOfDay usualWakeTime,
    required int prefId,
  }) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _accessToken = sharedPreferences.getString("access");

    String formattedUsualSleepTime = _formatTimeOfDay(usualSleepTime);
    String formattedUsualWakeTime = _formatTimeOfDay(usualWakeTime);

    if (_accessToken == null) {
      throw Exception('Access token is missing or invalid');
    }

    final url = Uri.parse("$_baseApiUrl/userprefs/$prefId/");

    try {
      final response = await http.patch(
        url,
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'usual_sleep_time': formattedUsualSleepTime,
          'usual_wake_time': formattedUsualWakeTime,
        }),
      );

      if (response.statusCode == 200) {
        final updatedPreferences =
            UserPreferences.fromJson(json.decode(response.body));

        // Update only sleep/wake times in the local state
        final index =
            _userPreferences.indexWhere((pref) => pref.prefId == prefId);
        if (index != -1) {
          _userPreferences[index] = UserPreferences(
            prefId: _userPreferences[index].prefId,
            usualSleepTime: updatedPreferences.usualSleepTime,
            usualWakeTime: updatedPreferences.usualWakeTime,
            reminderOffsetTime: _userPreferences[index].reminderOffsetTime,
          );
        }
        notifyListeners();
      } else {
        print("⚠️ Failed to update: ${response.statusCode}");
        print("Body: ${response.body}");
        throw Exception('Failed to update sleep and wake times');
      }
    } catch (error) {
      print("Error updating sleep and wake times: $error");
      throw Exception("Error: $error");
    }
  }

  // Save Reminder Offset Time
  Future<void> saveReminderOffsetTime({
    required String reminderOffsetTime,
    required int prefId,
  }) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _accessToken = sharedPreferences.getString("access");

    if (_accessToken == null) {
      throw Exception('Access token is missing or invalid');
    }

    final url = Uri.parse("$_baseApiUrl/userprefs/$prefId/");

    try {
      final response = await http.patch(
        url,
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'reminder_offset_time': reminderOffsetTime,
        }),
      );

      if (response.statusCode == 200) {
        final updatedPreferences =
            UserPreferences.fromJson(json.decode(response.body));

        // Update only reminder offset time in the local state
        final index =
            _userPreferences.indexWhere((pref) => pref.prefId == prefId);
        if (index != -1) {
          _userPreferences[index] = UserPreferences(
            prefId: _userPreferences[index].prefId,
            usualSleepTime: _userPreferences[index].usualSleepTime,
            usualWakeTime: _userPreferences[index].usualWakeTime,
            reminderOffsetTime: updatedPreferences.reminderOffsetTime,
          );
        }
        notifyListeners();
      } else {
        throw Exception('Failed to update reminder offset time');
      }
    } catch (error) {
      print("Error updating reminder offset time: $error");
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

  void resetState() {
    _userPreferences = [];
    notifyListeners();
  }
}
