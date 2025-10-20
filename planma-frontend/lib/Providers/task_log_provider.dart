import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:planma_app/models/task_time_log_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaskTimeLogProvider with ChangeNotifier {
  List<TaskTimeLog> _taskTimeLogs = [];
  String? _accessToken;

  List<TaskTimeLog> get taskTimeLogs => _taskTimeLogs;
  String? get accessToken => _accessToken;

  // Base API URL - adjust this to match your backend URL
  late final String _baseApiUrl;

  // Constructor to properly initialize the base URL
  TaskTimeLogProvider() {
    // Remove trailing slash if present in API_URL
    String baseUrl = dotenv.env['API_URL'] ??
        'http://https://planma-app-production.up.railway';
    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }
    _baseApiUrl = '$baseUrl/api';
  }

  //Fetch all task time logs
  Future<void> fetchTaskTimeLogs({String? startDate, String? endDate}) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _accessToken = sharedPreferences.getString("access");

    final url = Uri.parse(
        "$_baseApiUrl/task-logs/?start_date=$startDate&end_date=$endDate");

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

        // Parse the response body as a list of task time logs
        _taskTimeLogs = data.map((item) => TaskTimeLog.fromJson(item)).toList();
        notifyListeners();
      } else {
        throw Exception(
            'Failed to fetch task time logs. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      print("Error fetching task time logs: $error");
    }
  }

  // Add task time log
  Future<void> addTaskTimeLog({
    required int taskId,
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

    final url = Uri.parse("$_baseApiUrl/task-logs/log_time/");

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'task_id': taskId,
          'start_time': formattedStartTime,
          'end_time': formattedEndTime,
          'duration': formattedDuration,
          'date_logged': formattedScheduledDate,
        }),
      );

      if (response.statusCode == 201) {
        final newLog = TaskTimeLog.fromJson(json.decode(response.body));
        _taskTimeLogs.add(newLog);
        notifyListeners();
      } else if (response.statusCode == 400) {
        // Handle duplicate check from the backend
        final responseBody = json.decode(response.body);
        if (responseBody['error'] == 'Duplicate task time log detected.') {
          throw Exception('Duplicate task time log detected on the server.');
        } else {
          throw Exception('Error adding task time log: ${response.body}');
        }
      } else {
        throw Exception('Failed to add task time log: ${response.body}');
      }
    } catch (error) {
      print('Add task time log error: $error');
      throw Exception('Error adding task time log: $error');
    }
  }

  void resetState() {
    _taskTimeLogs = [];
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
