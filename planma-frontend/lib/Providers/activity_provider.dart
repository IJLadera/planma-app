import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:planma_app/models/activity_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ActivityProvider with ChangeNotifier {
  List<Activity> _activity = [];
  String? _accessToken;

  List<Activity> get activity => _activity;
  String? get accessToken => _accessToken;

  final String baseUrl = "http://127.0.0.1:8000/api/";

  //Fetch all activities
  Future<void> fetchActivity () async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _accessToken = sharedPreferences.getString("access");

    final url = Uri.parse("${baseUrl}activities/");

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
        _activity =
            data.map((item) => Activity.fromJson(item)).toList();
        notifyListeners();
      } else {
        throw Exception(
            'Failed to fetch Activities. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      print("Error fetching activities: $error");
    }
  }

  //Add a Activity
  Future<void> addActivity({
    required String activityName,
    required String activityDesc,
    required DateTime scheduledDate,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
  }) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _accessToken = sharedPreferences.getString("access");

    String formattedStartTime = _formatTimeOfDay(startTime);
    String formattedEndTime = _formatTimeOfDay(endTime);
    String formattedScheduledDate = DateFormat('yyyy-MM-dd').format(scheduledDate);

    bool isConflict = _activity.any((schedule) =>
      schedule.scheduledDate == scheduledDate &&
      schedule.scheduledStartTime == formattedStartTime &&
      schedule.scheduledEndTime == formattedEndTime);

    if (isConflict) {
      throw Exception(
          'Activity schedule conflict detected. Please modify your entry.');
    }

    bool isDuplicate = _activity.any((schedule) =>
      schedule.activityName == activityName &&
      schedule.activityDescription == activityDesc &&
      schedule.scheduledDate == scheduledDate &&
      schedule.scheduledStartTime == formattedStartTime &&
      schedule.scheduledEndTime == formattedEndTime);

    if (isDuplicate) {
      throw Exception(
          'Duplicate activity entry detected locally. Please modify your entry.');
    }

    final url = Uri.parse("${baseUrl}activities/add_activity/");
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'activity_name': activityName,
          'activity_desc': activityDesc,
          'scheduled_date': formattedScheduledDate,
          'scheduled_start_time': formattedStartTime,
          'scheduled_end_time': formattedEndTime,
        }),
      );

      if (response.statusCode == 201) {
        final newSchedule = Activity.fromJson(json.decode(response.body));
        _activity.add(newSchedule);
        notifyListeners();
      } else if (response.statusCode == 400) {
        // Handle duplicate check from the backend
        final responseBody = json.decode(response.body);
        if (responseBody['error'] == 'Duplicate activity entry detected.') {
          throw Exception('Duplicate activity entry detected on the server.');
        } else {
          throw Exception('Error adding activity: ${response.body}');
        }
      } else {
        throw Exception('Failed to add activity: ${response.body}');
      }

    } catch (error) {
      print('Add activity error: $error');
      throw Exception('Error adding activity: $error');
    }
  }

  // Edit a activity
  Future<void> updateActivity({
    required int activityId,
    required String activityName,
    required String activityDesc,
    required DateTime scheduledDate,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
  }) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _accessToken = sharedPreferences.getString("access");

    String formattedStartTime = _formatTimeOfDay(startTime);
    String formattedEndTime = _formatTimeOfDay(endTime);
    String formattedScheduledDate = DateFormat('yyyy-MM-dd').format(scheduledDate);

    bool isConflict = _activity.any((schedule) =>
      schedule.activityId != activityId &&
      schedule.scheduledDate == scheduledDate &&
      schedule.scheduledStartTime == formattedStartTime &&
      schedule.scheduledEndTime == formattedEndTime);

    if (isConflict) {
      throw Exception(
          'Activity schedule conflict detected. Please modify your entry.');
    }

    bool isDuplicate = _activity.any((schedule) =>
      schedule.activityName == activityName &&
      schedule.activityDescription == activityDesc &&
      schedule.scheduledDate == scheduledDate &&
      schedule.scheduledStartTime == formattedStartTime &&
      schedule.scheduledEndTime == formattedEndTime);

    if (isDuplicate) {
      throw Exception(
          'Duplicate activity entry detected locally. Please modify your entry.');
    }

    final url = Uri.parse("${baseUrl}activities/$activityId/");

    print('FROM PROVIDER:');
    print('activity Name: $activityName');
    print('activity Description: $activityDesc');
    print('Scheduled Date: $formattedScheduledDate');
    print('Start Time: $formattedStartTime');
    print('End Time: $formattedEndTime');

    try {
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'activity_name': activityName,
          'activity_desc': activityDesc,
          'scheduled_date': formattedScheduledDate,
          'scheduled_start_time': formattedStartTime,
          'scheduled_end_time': formattedEndTime,
        }),
      );

      if (response.statusCode == 200) {
        final updatedSchedule = Activity.fromJson(json.decode(response.body));
        final index = _activity
            .indexWhere((schedule) => schedule.activityId == activityId);
        if (index != -1) {
          _activity[index] = updatedSchedule;
          notifyListeners();
        }
      } else if (response.statusCode == 400) {
        // Handle duplicate check from the backend
        final responseBody = json.decode(response.body);
        if (responseBody['error'] == 'Duplicate activity entry detected.') {
          throw Exception('Duplicate activity entry detected on the server.');
        } else {
          throw Exception('Error updating activity: ${response.body}');
        }
      } else {
        throw Exception('Failed to update activity: ${response.body}');
      }
    } catch (error) {
      print('Update activity error: $error');
      throw Exception('Error updating activity: $error');
    }
  }

  // Delete a activity
  Future<void> deleteActivity(int activityId) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _accessToken = sharedPreferences.getString("access");

    final url = Uri.parse("${baseUrl}activities/$activityId/");

    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $_accessToken',
        },
      );

      if (response.statusCode == 204) {
        _activity
            .removeWhere((schedule) => schedule.activityId == activityId);
        notifyListeners();
      } else {
        throw Exception(
            'Failed to delete activity. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      rethrow;
    }    
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

  void resetState() {
    _activity = [];
    notifyListeners();
  }
}
