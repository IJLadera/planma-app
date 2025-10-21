import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:planma_app/models/goal_progress_model.dart';
import 'package:planma_app/models/goals_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoalProgressProvider with ChangeNotifier {
  List<GoalProgress> _goalProgressLogs = [];
  Map<int, List<GoalProgress>> _goalProgressLogsPerGoal = {};
  String? _accessToken;

  List<GoalProgress> get goalProgressLogs => _goalProgressLogs;
  Map<int, List<GoalProgress>> get goalProgressLogsPerGoal =>
      _goalProgressLogsPerGoal;
  String? get accessToken => _accessToken;

  // Base API URL - adjust this to match your backend URL
  late final String _baseApiUrl;

  GoalProgressProvider() {
    // Remove trailing slash if present in API_URL
    String baseUrl =
        dotenv.env['API_URL'] ?? 'http://planma-app-production.up.railway.app';
    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }
    _baseApiUrl = '$baseUrl/api';
  }

  //Fetch all goal progress records
  Future<void> fetchGoalProgress({String? startDate, String? endDate}) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _accessToken = sharedPreferences.getString("access");

    final url = Uri.parse(
        "$_baseApiUrl/goal-progress/?start_date=$startDate&end_date=$endDate");

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $_accessToken'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _goalProgressLogs =
            data.map((item) => GoalProgress.fromJson(item)).toList();
        notifyListeners();
      } else {
        throw Exception(
            'Failed to fetch goal progress logs. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching goal progress: $e");
    }
  }

  //Fetch goal progress per goal
  Future<void> fetchGoalProgressPerGoal(Goal goal) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _accessToken = sharedPreferences.getString("access");

    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    String? startDate;
    String endDate = formatter.format(now);

    if (goal.timeframe == 'Daily') {
      startDate = endDate;
    } else if (goal.timeframe == 'Weekly') {
      startDate =
          formatter.format(now.subtract(Duration(days: now.weekday - 1)));
    } else if (goal.timeframe == 'Monthly') {
      startDate = formatter.format(DateTime(now.year, now.month, 1));
    }

    final url = Uri.parse(
        "$_baseApiUrl/goal-progress/?goal_id=${goal.goalId}&start_date=$startDate&end_date=$endDate");

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $_accessToken'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _goalProgressLogsPerGoal[goal.goalId!] =
            data.map((item) => GoalProgress.fromJson(item)).toList();
        notifyListeners();
      } else {
        throw Exception(
            'Failed to fetch goal progress logs. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching goal progress: $e");
    }
  }

  double computeProgress(int goalId, int targetHours, String timeframe) {
    double totalLoggedHours = 0;

    if (_goalProgressLogsPerGoal.containsKey(goalId)) {
      for (var log in _goalProgressLogsPerGoal[goalId]!) {
        totalLoggedHours += _convertDurationToDouble(log.duration);
      }
    }

    final int timeframeFactor = timeframe == 'Weekly'
        ? 7
        : timeframe == 'Monthly'
            ? 30
            : 1;

    final adjustedTarget = targetHours * timeframeFactor;
    print(
        "Total Time Spent based on Timeframe: ${(adjustedTarget > 0) ? totalLoggedHours / adjustedTarget : 0.0}");
    return (adjustedTarget > 0) ? totalLoggedHours / adjustedTarget : 0.0;
  }

  double _convertDurationToDouble(String duration) {
    try {
      final parts = duration.split(':').map(int.parse).toList();
      return parts[0] + (parts[1] / 60) + (parts[2] / 3600);
    } catch (e) {
      print("Error parsing duration: $e");
      return 0.0;
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

    final url = Uri.parse("$_baseApiUrl/goal-progress/log_time/");

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
          throw Exception(
              'Duplicate goal progress log detected on the server.');
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
