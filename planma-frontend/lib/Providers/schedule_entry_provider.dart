import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:planma_app/models/schedule_entry_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ScheduleEntryProvider with ChangeNotifier {
  List<ScheduleEntry> _scheduleEntries = [];
  String? _accessToken;

  List<ScheduleEntry> get scheduleEntries => _scheduleEntries;
  String? get accessToken => _accessToken;

  final String baseUrl = "http://127.0.0.1:8000/api/";

  Future<void> fetchScheduleEntries() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _accessToken = sharedPreferences.getString("access");

    final url = Uri.parse("${baseUrl}schedule/");

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

    final url = Uri.parse("${baseUrl}events/$referenceId/");

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

    final url = Uri.parse("${baseUrl}tasks/$referenceId/");

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

    final url = Uri.parse("${baseUrl}activities/$referenceId/");

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

    final url = Uri.parse("${baseUrl}goal-schedules/$referenceId/");

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

    final url = Uri.parse("${baseUrl}class-schedules/$referenceId/");

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
}
