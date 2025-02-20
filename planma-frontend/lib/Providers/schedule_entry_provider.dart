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
        _scheduleEntries = data.map((item) => ScheduleEntry.fromJson(item)).toList();
        notifyListeners();
      } else {
        throw Exception('Failed to fetch schedule entries. Status Code: ${response.statusCode}');
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

  Future<String> fetchTaskName(int referenceId) async {
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
        return data["task_name"];
      } else {
        return "Unknown Task";
      }
    } catch (error) {
      print("Error fetching task name: $error");
      return "Unknown Task";
    }
  }

  Future<String> fetchActivityName(int referenceId) async {
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
        return data["activity_name"];
      } else {
        return "Unknown Activity";
      }
    } catch (error) {
      print("Error fetching activity name: $error");
      return "Unknown Activity";
    }
  }

  Future<String> fetchGoalName(int referenceId) async {
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
        return data["goal_id"]['goal_name'];
      } else {
        return "Unknown Goal";
      }
    } catch (error) {
      print("Error fetching Goal name: $error");
      return "Unknown Goal";
    }
  }
}