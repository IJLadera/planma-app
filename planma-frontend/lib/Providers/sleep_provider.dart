import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:planma_app/models/sleep_log_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SleepLogProvider with ChangeNotifier {
  List<SleepLog> _sleepLogs = [];
  String? _accessToken;

  List<SleepLog> get sleepLogs => _sleepLogs;
  String? get accessToken => _accessToken;

  final String baseUrl = "http://127.0.0.1:8000/api/";

  // Fetch all sleep log records
  Future<void> fetchSleepLogs ({String? startDate, String? endDate}) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _accessToken = sharedPreferences.getString("access");

    final url = Uri.parse("${baseUrl}sleep-logs/?start_date=$startDate&end_date=$endDate");

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

        // Parse the response body as a list of sleep logs
        _sleepLogs =
            data.map((item) => SleepLog.fromJson(item)).toList();
        notifyListeners();
      } else {
        throw Exception(
            'Failed to fetch sleep logs. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      print("Error fetching sleep logs: $error");
    }
  }

  // Add sleep log
  Future<void> addSleepLog({
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

    final url = Uri.parse("${baseUrl}sleep-logs/log_time/");

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'start_time': formattedStartTime,
          'end_time': formattedEndTime,
          'duration': formattedDuration,
          'date_logged': formattedScheduledDate,
        }),
      );

      if (response.statusCode == 201) {
        final newLog = SleepLog.fromJson(json.decode(response.body));
        _sleepLogs.add(newLog);
        notifyListeners();
      } else if (response.statusCode == 400) {
        // Handle duplicate check from the backend
        final responseBody = json.decode(response.body);
        if (responseBody['error'] == 'Duplicate sleep log detected.') {
          throw Exception('Duplicate sleep log detected on the server.');
        } else {
          throw Exception('Error adding sleep log: ${response.body}');
        }
      } else {
        throw Exception('Failed to add sleep log: ${response.body}');
      }

    } catch (error) {
      print('Add sleep log error: $error');
      throw Exception('Error adding sleep log: $error');
    }
  }

  void resetState() {
    _sleepLogs = [];
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