import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:planma_app/models/activity_time_log_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ActivityTimeLogProvider with ChangeNotifier {
  List<ActivityTimeLog> _activityTimeLogs = [];
  String? _accessToken;

  List<ActivityTimeLog> get activityTimeLogs => _activityTimeLogs;
  String? get accessToken => _accessToken;

  // Base API URL - adjust this to match your backend URL
  late final String _baseApiUrl;

  ActivityTimeLogProvider() {
    // Remove trailing slash if present in API_URL
    String baseUrl = dotenv.env['API_URL'] ?? 'http://localhost:8000';
    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }
    _baseApiUrl = '$baseUrl/api';
  }

  //Fetch all activity time logs
  Future<void> fetchActivityTimeLogs ({String? startDate, String? endDate}) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _accessToken = sharedPreferences.getString("access");

    final url = Uri.parse("$_baseApiUrl/activity-logs/?start_date=$startDate&end_date=$endDate");

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $_accessToken',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        // Parse the response body as a list of activity time logs
        _activityTimeLogs =
            data.map((item) => ActivityTimeLog.fromJson(item)).toList();
        notifyListeners();
      } else {
        throw Exception(
            'Failed to fetch activity time logs. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      print("Error fetching activity time logs: $error");
    }
  }

  // Add activity time log
  Future<void> addActivityTimeLog({
    required int activityId,
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

    final url = Uri.parse("$_baseApiUrl/activity-logs/log_time/");

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'activity_id': activityId,
          'start_time': formattedStartTime,
          'end_time': formattedEndTime,
          'duration': formattedDuration,
          'date_logged': formattedScheduledDate,
        }),
      );

      if (response.statusCode == 201) {
        final newLog = ActivityTimeLog.fromJson(json.decode(response.body));
        _activityTimeLogs.add(newLog);
        notifyListeners();
      } else if (response.statusCode == 400) {
        // Handle duplicate check from the backend
        final responseBody = json.decode(response.body);
        if (responseBody['error'] == 'Duplicate activity time log detected.') {
          throw Exception('Duplicate activity time log detected on the server.');
        } else {
          throw Exception('Error adding activity time log: ${response.body}');
        }
      } else {
        throw Exception('Failed to add activity time log: ${response.body}');
      }

    } catch (error) {
      print('Add activity time log error: $error');
      throw Exception('Error adding activity time log: $error');
    }
  }

  void resetState() {
    _activityTimeLogs = [];
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