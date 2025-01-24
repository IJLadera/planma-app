import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:planma_app/models/goal_progress_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoalProgressProvider with ChangeNotifier {
  List<GoalProgress> _goalProgressLogs = [];
  String? _accessToken;

  List<GoalProgress> get goalProgressLogs => _goalProgressLogs;
  String? get accessToken => _accessToken;

  final String baseUrl = "http://127.0.0.1:8000/api/";

  //Fetch all goal progress logs
  Future<void> fetchGoalProgressLogs () async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _accessToken = sharedPreferences.getString("access");

    final url = Uri.parse("${baseUrl}goal-progress/");

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $_accessToken',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        // print(data);

        // Parse the response body as a list of goal progress logs
        _goalProgressLogs =
            data.map((item) => GoalProgress.fromJson(item)).toList();
        notifyListeners();
      } else {
        throw Exception(
            'Failed to fetch goal progress logs. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      print("Error fetching goal progress logs: $error");
    }
  }

  // Add goal progress log
  Future<void> addGoalProgressLog({
    required int goalId,
    required int goalScheduleId,
    required DateTime startTime,
    required DateTime endTime,
    required Duration duration,
    required DateTime dateLogged, 
  }) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _accessToken = sharedPreferences.getString("access");

    String formattedStartTime = _formatDateTime(startTime);
    String formattedEndTime = _formatDateTime(endTime);
    String formattedDuration = _formatDuration(duration);
    String formattedScheduledDate = DateFormat('yyyy-MM-dd').format(dateLogged);

    final url = Uri.parse("${baseUrl}goal-progress/log_time/");

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'goal_id': goalId,
          'goalschedule_id': goalScheduleId,
          'session_start_time': formattedStartTime,
          'session_end_time': formattedEndTime,
          'session_duration': formattedDuration,
          'session_date': formattedScheduledDate,
        }),
      );

      if (response.statusCode == 201) {
        final newLog = GoalProgress.fromJson(json.decode(response.body));
        _goalProgressLogs.add(newLog);
        notifyListeners();
      } else if (response.statusCode == 400) {
        // Handle duplicate check from the backend
        final responseBody = json.decode(response.body);
        if (responseBody['error'] == 'Duplicate goal progress log detected.') {
          throw Exception('Duplicate goal progress log detected on the server.');
        } else {
          throw Exception('Error adding goal progress log: ${response.body}');
        }
      } else {
        throw Exception('Failed to add goal progress log: ${response.body}');
      }

    } catch (error) {
      print('Add goal progress log error: $error');
      throw Exception('Error adding goal progress log: $error');
    }
  }

  void resetState() {
    _goalProgressLogs = [];
    notifyListeners();
  }

  // Utility method to format TimeOfDay to HH:mm:ss
  String _formatDateTime(DateTime dateTime) {
    return DateFormat('HH:mm:ss').format(dateTime);
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }
}