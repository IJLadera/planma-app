import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:planma_app/models/goal_schedules_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoalScheduleProvider extends ChangeNotifier {
  List<GoalSchedule> _pendingGoalschedules = [];
  List<GoalSchedule> _completedGoalschedules = [];
  List<GoalSchedule> _goalschedules = [];
  String? _accessToken;

  List<GoalSchedule> get pendingGoalschedules => _pendingGoalschedules;
  List<GoalSchedule> get completedGoalschedules => _completedGoalschedules;
  List<GoalSchedule> get goalschedules => _goalschedules;
  String? get accessToken => _accessToken;

  final String baseUrl = "http://127.0.0.1:8000/api/";

  //Fetch all goal schedules
  Future<void> fetchGoalSchedules() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _accessToken = sharedPreferences.getString("access");

    final url = Uri.parse("${baseUrl}goal-schedules/");

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
        _goalschedules =
            data.map((item) => GoalSchedule.fromJson(item)).toList();
        notifyListeners();
      } else {
        throw Exception(
            'Failed to fetch goal schedules. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      print("Error fetching goal schedules: $error");
    }
  }

  //Fetch specific goal schedules
  Future<void> fetchGoalSchedulesPerGoal(int goalId) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _accessToken = sharedPreferences.getString("access");

    final url = Uri.parse("${baseUrl}goal-schedules/?goal_id=$goalId");

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $_accessToken',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _goalschedules =
            data.map((item) => GoalSchedule.fromJson(item)).toList();
        notifyListeners();
      } else {
        throw Exception(
            'Failed to fetch goal schedules. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      print("Error fetching goal schedules: $error");
    }
  }

  // Fetch pending goal schedules per goal
  Future<void> fetchPendingGoalSchedules (int goalId) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _accessToken = sharedPreferences.getString("access");

    final url = Uri.parse("${baseUrl}goal-schedules/pending_goal_schedules/?goal_id=$goalId");

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $_accessToken',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final newSchedules = data.map((item) => GoalSchedule.fromJson(item)).toList();

        // Merge new schedules into the master list
        _goalschedules.addAll(newSchedules.where((newSchedule) => !_goalschedules.any(
              (existingSchedule) => existingSchedule.goalScheduleId == newSchedule.goalScheduleId)));

        _sortGoalSchedules(); // Reorganize goal schedules
      } else {
        throw Exception(
            'Failed to fetch goal schedules. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      print("Error fetching goal schedules: $error");
    }
  }

  // Fetch completed goal schedules per goal
  Future<void> fetchCompletedGoalSchedules (int goalId) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _accessToken = sharedPreferences.getString("access");

    final url = Uri.parse("${baseUrl}goal-schedules/completed_goal_schedules/?goal_id=$goalId");

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $_accessToken',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final newSchedules = data.map((item) => GoalSchedule.fromJson(item)).toList();

        // Merge new schedules into the master list
        _goalschedules.addAll(newSchedules.where((newSchedule) => !_goalschedules.any(
              (existingSchedule) => existingSchedule.goalScheduleId == newSchedule.goalScheduleId)));

        _sortGoalSchedules(); // Reorganize goal schedules
      } else {
        throw Exception(
            'Failed to fetch goal schedules. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      print("Error fetching goal schedules: $error");
    }
  }

  // Update goal schedule status dynamically
  void updateGoalScheduleStatus(int goalScheduleId, String newStatus) {
    // Find the goal schedule in the pending list
    final scheduleIndex = _pendingGoalschedules.indexWhere((schedule) => schedule.goalScheduleId == goalScheduleId);
    if (scheduleIndex != -1) {
      final schedule = _pendingGoalschedules[scheduleIndex];
      schedule.status = newStatus;

      // Move goal schedule from pending to completed if status is "Completed"
      if (newStatus == "Completed") {
        _completedGoalschedules.add(schedule);
        _pendingGoalschedules.removeAt(scheduleIndex);
      }

      notifyListeners();
    }
  }

  //Add a goal schedule
  Future<void> addGoalSchedule({
    required int goalId,
    required DateTime scheduledDate,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
  }) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _accessToken = sharedPreferences.getString("access");

    String formattedStartTime = _formatTimeOfDay(startTime);
    String formattedEndTime = _formatTimeOfDay(endTime);
    String formattedScheduledDate = DateFormat('yyyy-MM-dd').format(scheduledDate);

    bool isConflict = _goalschedules.any((schedule) =>
      schedule.scheduledDate == scheduledDate &&
      schedule.scheduledStartTime == formattedStartTime &&
      schedule.scheduledEndTime == formattedEndTime);

    if (isConflict) {
      throw Exception(
          'Goal schedule conflict detected. Please modify your entry.');
    }

    bool isDuplicate = _goalschedules.any((schedule) =>
      schedule.goal?.goalId == goalId &&
      schedule.scheduledDate == scheduledDate &&
      schedule.scheduledStartTime == formattedStartTime &&
      schedule.scheduledEndTime == formattedEndTime);

    if (isDuplicate) {
      throw Exception(
          'Duplicate goal entry detected locally. Please modify your entry.');
    }

    final url = Uri.parse("${baseUrl}goal-schedules/add_schedule/");

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'goal_id': goalId,
          'scheduled_date': formattedScheduledDate,
          'scheduled_start_time': formattedStartTime,
          'scheduled_end_time': formattedEndTime,
        }),
      );

      if (response.statusCode == 201) {
        final newSchedule = GoalSchedule.fromJson(json.decode(response.body));
        _goalschedules.add(newSchedule);
        _sortGoalSchedules();
      } else if (response.statusCode == 400) {
        // Handle duplicate check from the backend
        final responseBody = json.decode(response.body);
        if (responseBody['error_type'] == 'overlap') {
          throw Exception(
              'Scheduling overlap: ${responseBody['message']}');
        } else if (responseBody['error'] == 'Duplicate goal schedule detected.') {
          throw Exception('Duplicate goal schedule detected on the server.');
        } else {
          throw Exception('Error adding goal schedule: ${response.body}');
        }
      } else {
        throw Exception('Failed to add goal schedule: ${response.body}');
      }

    } catch (error) {
      print('Add goal schedule error: $error');
      throw Exception('Error adding goal schedule: $error');
    }
  }

  // Edit a goal schedule
  Future<void> updateGoalSchedule({
    required int goalScheduleId,
    required int goalId,
    required DateTime scheduledDate,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
  }) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _accessToken = sharedPreferences.getString("access");

    String formattedStartTime = _formatTimeOfDay(startTime);
    String formattedEndTime = _formatTimeOfDay(endTime);
    String formattedScheduledDate = DateFormat('yyyy-MM-dd').format(scheduledDate);

    bool isConflict = _goalschedules.any((schedule) =>
      schedule.scheduledDate == scheduledDate &&
      schedule.scheduledStartTime == formattedStartTime &&
      schedule.scheduledEndTime == formattedEndTime);

    if (isConflict) {
      throw Exception(
          'Goal schedule conflict detected. Please modify your entry.');
    }

    bool isDuplicate = _goalschedules.any((schedule) =>
      schedule.goal?.goalId == goalId &&
      schedule.scheduledDate == scheduledDate &&
      schedule.scheduledStartTime == formattedStartTime &&
      schedule.scheduledEndTime == formattedEndTime);

    if (isDuplicate) {
      throw Exception(
          'Duplicate goal entry detected locally. Please modify your entry.');
    }

    final url = Uri.parse("${baseUrl}goal-schedules/$goalScheduleId/");

    try {
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'goal_id': goalId,
          'scheduled_date': formattedScheduledDate,
          'scheduled_start_time': formattedStartTime,
          'scheduled_end_time': formattedEndTime,
        }),
      );

      if (response.statusCode == 200) {
        final updatedSchedule = GoalSchedule.fromJson(json.decode(response.body));
        final index = _goalschedules
            .indexWhere((schedule) => schedule.goalScheduleId == goalScheduleId);
        if (index != -1) {
          _goalschedules[index] = updatedSchedule;
          _sortGoalSchedules();
        }
      } else if (response.statusCode == 400) {
        // Handle duplicate check from the backend
        final responseBody = json.decode(response.body);
        if (responseBody['error_type'] == 'overlap') {
          throw Exception(
              'Scheduling overlap: ${responseBody['message']}');
        } else if (responseBody['error'] == 'Duplicate goal schedule detected.') {
          throw Exception('Duplicate goal schedule detected on the server.');
        } else {
          throw Exception('Error adding goal schedule: ${response.body}');
        }
      } else {
        throw Exception('Failed to update goal schedule: ${response.body}');
      }
    } catch (error) {
      print('Update goal schedule error: $error');
      throw Exception('Error updating goal schedule: $error');
    }
  }  

  // Delete a goal schedule
  Future<void> deleteGoalSchedule(int goalScheduleId) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _accessToken = sharedPreferences.getString("access");

    final url = Uri.parse("${baseUrl}goal-schedules/$goalScheduleId/");

    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $_accessToken',
        },
      );

      if (response.statusCode == 204) {
        _goalschedules
            .removeWhere((schedule) => schedule.goalScheduleId == goalScheduleId);
        _sortGoalSchedules();
        notifyListeners();
      } else {
        throw Exception(
            'Failed to delete goal entry. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      rethrow;
    }    
  }

  void resetState() {
    _goalschedules = [];
    notifyListeners();
  }

  // Utility method to format TimeOfDay to HH:mm:ss
  String _formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dateTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    return DateFormat('HH:mm:ss').format(dateTime);
  }

  // Utility method to sort activities if it is pending or completed.
  void _sortGoalSchedules() {
    _pendingGoalschedules = _goalschedules
        .where((schedule) =>
            schedule.status == 'Pending')
        .toList();

    _completedGoalschedules = _goalschedules
        .where((schedule) =>
            schedule.status == 'Completed')
        .toList();

    notifyListeners();
  }
}