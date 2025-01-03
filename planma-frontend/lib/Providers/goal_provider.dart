import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:planma_app/models/goals_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoalProvider extends ChangeNotifier {
  List<Goal> _goals = [];
  String? _accessToken;

  List<Goal> get goals => _goals;
  String? get accessToken => _accessToken;

  final String baseUrl = "http://127.0.0.1:8000/api/";

  //Fetch all goals
  Future<void> fetchGoals() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _accessToken = sharedPreferences.getString("access");

    final url = Uri.parse("${baseUrl}goals/");

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

        // Parse the response body as a list of class schedules
        _goals = data.map((item) => Goal.fromJson(item)).toList();
        notifyListeners();
      } else {
        throw Exception(
            'Failed to fetch goals. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      print("Error fetching goals: $error");
    }
  }

  //Add a goal
  Future<void> addGoal({
    required String goalName,
    required String goalDescription,
    required String timeframe,
    required Duration targetHours,
    required String goalType,
    required int? semester,
  }) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _accessToken = sharedPreferences.getString("access");

    int formattedTargetHours = targetHours.inHours;

    bool isDuplicate = _goals.any((schedule) =>
        schedule.goalName == goalName &&
        schedule.timeframe == timeframe &&
        schedule.targetHours == targetHours &&
        schedule.goalType == goalType);

    if (isDuplicate) {
      throw Exception(
          'Duplicate goal entry detected locally. Please modify your entry.');
    }

    // If the goal type is "Personal", set semester to null
    int? finalSemester = (goalType == "Personal") ? null : semester;

    final url = Uri.parse("${baseUrl}goals/add_goal/");
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'goal_name': goalName,
          'goal_desc': goalDescription,
          'timeframe': timeframe,
          'target_hours': formattedTargetHours,
          'goal_type': goalType,
          'semester_id': finalSemester,
        }),
      );

      if (response.statusCode == 201) {
        final newSchedule = Goal.fromJson(json.decode(response.body));
        _goals.add(newSchedule);
        notifyListeners();
      } else if (response.statusCode == 400) {
        // Handle duplicate check from the backend
        final responseBody = json.decode(response.body);
        if (responseBody['error'] == 'Duplicate goal entry detected.') {
          throw Exception('Duplicate goal entry detected on the server.');
        } else {
          throw Exception('Error adding goal: ${response.body}');
        }
      } else {
        throw Exception('Failed to add goal: ${response.body}');
      }
    } catch (error) {
      print('Add goal error: $error');
      throw Exception('Error adding goal: $error');
    }
  }

  // Edit a goal
  Future<void> updateGoal({
    required int goalId,
    required String goalName,
    required String goalDescription,
    required String timeframe,
    required Duration targetHours,
    required String goalType,
    required int? semester,
  }) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _accessToken = sharedPreferences.getString("access");

    int formattedTargetHours = targetHours.inHours;

    bool isDuplicate = _goals.any((schedule) =>
        schedule.goalName == goalName &&
        schedule.timeframe == timeframe &&
        schedule.targetHours == targetHours &&
        schedule.goalType == goalType);

    if (isDuplicate) {
      throw Exception(
          'Duplicate goal entry detected locally. Please modify your entry.');
    }

    // If the goal type is "Personal", set semester to null
    int? finalSemester = (goalType == "Personal") ? null : semester;

    final url = Uri.parse("${baseUrl}goals/$goalId/");

    try {
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'goal_name': goalName,
          'goal_desc': goalDescription,
          'timeframe': timeframe,
          'target_hours': formattedTargetHours,
          'goal_type': goalType,
          'semester_id': finalSemester,
        }),
      );

      if (response.statusCode == 200) {
        final updatedSchedule = Goal.fromJson(json.decode(response.body));
        final index =
            _goals.indexWhere((schedule) => schedule.goalId == goalId);
        if (index != -1) {
          _goals[index] = updatedSchedule;
          notifyListeners();
        }
      } else if (response.statusCode == 400) {
        // Handle duplicate check from the backend
        final responseBody = json.decode(response.body);
        if (responseBody['error'] == 'Duplicate goal entry detected.') {
          throw Exception('Duplicate goal entry detected on the server.');
        } else {
          throw Exception('Error updating goal: ${response.body}');
        }
      } else {
        throw Exception('Failed to update goal: ${response.body}');
      }
    } catch (error) {
      print('Update goal error: $error');
      throw Exception('Error updating goal: $error');
    }
  }

  // Delete a goal
  Future<void> deleteGoal(int goalId) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _accessToken = sharedPreferences.getString("access");

    final url = Uri.parse("${baseUrl}goals/$goalId/");

    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $_accessToken',
        },
      );

      if (response.statusCode == 204) {
        _goals.removeWhere((schedule) => schedule.goalId == goalId);
        notifyListeners();
      } else {
        throw Exception(
            'Failed to delete goal. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      rethrow;
    }
  }
}
