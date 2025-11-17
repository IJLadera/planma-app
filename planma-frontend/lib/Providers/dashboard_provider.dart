import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class DashboardProvider with ChangeNotifier {
  // Data containers
  List<dynamic> semesters = [];
  int? selectedSemesterId;
  List<dynamic> classSchedule = [];
  List<dynamic> pendingTasks = [];
  List<dynamic> upcomingEvents = [];
  List<dynamic> pendingActivities = [];
  List<dynamic> goals = [];
  Map<String, dynamic> preferences = {};

  bool isLoading = false;
  String? errorMessage;

  final String baseApiUrl;
  final Future<String?> Function() tokenProvider;

  DashboardProvider({required this.baseApiUrl, required this.tokenProvider});

  void _applyJson(Map<String, dynamic> jsonData, {bool notify = true}) {
    semesters = List.from(jsonData['semesters'] ?? []);
    selectedSemesterId = jsonData['selected_semester_id'];
    classSchedule = List.from(jsonData['class_schedule'] ?? []);
    pendingTasks = List.from(jsonData['pending_tasks'] ?? []);
    upcomingEvents = List.from(jsonData['upcoming_events'] ?? []);
    pendingActivities = List.from(jsonData['pending_activities'] ?? []);
    goals = List.from(jsonData['goals'] ?? []);
    preferences = Map<String, dynamic>.from(jsonData['preferences'] ?? {});
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
