import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class DashboardProvider with ChangeNotifier {
  int classScheduleCount = 0;
  int pendingTasksCount = 0;
  int upcomingEventsCount = 0;
  int pendingActivitiesCount = 0;
  int goalsCount = 0;

  bool isLoading = false;
  String? errorMessage;

  final String baseApiUrl;
  final Future<String?> Function() tokenProvider;

  DashboardProvider({required this.baseApiUrl, required this.tokenProvider});

  void _applyJson(Map<String, dynamic> jsonData, {bool notify = true}) {
    classScheduleCount = jsonData['class_schedule_count'] ?? 0;
    pendingTasksCount = jsonData['pending_tasks_count'] ?? 0;
    upcomingEventsCount = jsonData['upcoming_events_count'] ?? 0;
    pendingActivitiesCount = jsonData['pending_activities_count'] ?? 0;
    goalsCount = jsonData['goals_count'] ?? 0;

    if (notify) notifyListeners();
  }

  Future<void> fetchDashboardData({bool forceRefresh = false}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final token = await tokenProvider();
    if (token == null) {
      errorMessage = 'No access token';
      isLoading = false;
      notifyListeners();
      return;
    }

    final url = Uri.parse('$baseApiUrl/api/dashboard/');
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        _applyJson(jsonData);
      } else {
        errorMessage = 'Server error: ${response.statusCode}';
        print('Dashboard fetch error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      errorMessage = 'Network error: $e';
      print('Dashboard fetch exception: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

