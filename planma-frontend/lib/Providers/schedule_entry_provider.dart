import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:planma_app/models/schedule_entry_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ScheduleEntryProvider with ChangeNotifier {
  List<ScheduleEntry> _scheduleEntries = [];
  String? _accessToken;

  List<ScheduleEntry> get scheduleEntries => _scheduleEntries;
  String? get accessToken => _accessToken;

  // Base API URL - adjust this to match your backend URL
  late final String _baseApiUrl;

  // Constructor to properly initialize the base URL
  ScheduleEntryProvider() {
    // Remove trailing slash if present in API_URL
    String baseUrl =
        dotenv.env['API_URL'] ?? 'https://planma-app-production.up.railway.app';
    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }
    _baseApiUrl = '$baseUrl/api';
  }

  Future<void> fetchScheduleEntries() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _accessToken = sharedPreferences.getString("access");

    final url = Uri.parse("$_baseApiUrl/schedule/");

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $_accessToken',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _scheduleEntries =
            data.map((item) => ScheduleEntry.fromJson(item)).toList();
        notifyListeners();
      } else {
        throw Exception(
            'Failed to fetch schedule entries. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      print("Error fetching schedule entries: $error");
    }
  }

  Future<String> fetchEventName(int referenceId) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _accessToken = sharedPreferences.getString("access");

    final url = Uri.parse("$_baseApiUrl/events/$referenceId/");

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $_accessToken',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data["event_name"];
      } else {
        return "Unknown Event";
      }
    } catch (error) {
      print("Error fetching event name: $error");
      return "Unknown Event";
    }
  }

  Future<Map<String, dynamic>> fetchTaskDetails(int referenceId) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _accessToken = sharedPreferences.getString("access");

    final url = Uri.parse("$_baseApiUrl/tasks/$referenceId/");

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $_accessToken',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return {
          "task_name": data["task_name"],
          "status": data["status"] ?? "Pending", // Default to "Pending" if null
        };
      } else {
        return {
          "task_name": "Unknown Task",
          "status": "Unknown Status",
        };
      }
    } catch (error) {
      print("Error fetching task details: $error");
      return {
        "task_name": "Unknown Task",
        "status": "Unknown Status",
      };
    }
  }

  Future<Map<String, dynamic>> fetchActivityDetails(int referenceId) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _accessToken = sharedPreferences.getString("access");

    final url = Uri.parse("$_baseApiUrl/activities/$referenceId/");

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $_accessToken',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return {
          "activity_name": data["activity_name"],
          "status": data["status"] ?? "Pending", // Default to "Pending" if null
        };
      } else {
        return {
          "activity_name": "Unknown Activity",
          "status": "Unknown Status",
        };
      }
    } catch (error) {
      print("Error fetching activity details: $error");
      return {
        "activity_name": "Unknown Task",
        "status": "Unknown Status",
      };
    }
  }

  Future<Map<String, dynamic>> fetchGoalDetails(int referenceId) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _accessToken = sharedPreferences.getString("access");

    final url = Uri.parse("$_baseApiUrl/goal-schedules/$referenceId/");

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $_accessToken',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return {
          "goal_name": data["goal_id"]?["goal_name"] ?? "Unknown Goal",
          "status": data.containsKey("status")
              ? data["status"]
              : "Pending", // Default to "Pending" if null
        };
      } else {
        return {
          "goal_name": "Unknown Goal",
          "status": "Unknown Status",
        };
      }
    } catch (error) {
      print("Error fetching Goal details: $error");
      return {
        "goal_name": "Unknown Goal",
        "status": "Unknown Status",
      };
    }
  }

  Future<String> fetchClassDetails(int referenceId) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _accessToken = sharedPreferences.getString("access");

    final url = Uri.parse("$_baseApiUrl/class-schedules/$referenceId/");

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $_accessToken',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data["subject"]?["subject_code"] ?? "Unknown Classs";
      } else {
        return "Unknown Class";
      }
    } catch (error) {
      print("Error fetching class details: $error");
      return "Unknown Class";
    }
  }

  void resetState() {
    _scheduleEntries = [];
    notifyListeners();
  }
}
