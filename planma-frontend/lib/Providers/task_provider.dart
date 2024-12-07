import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:planma_app/models/tasks_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  String? _accessToken;

  List<Task> get tasks => _tasks;
  String? get accessToken => _accessToken;

  final String baseUrl = "http://127.0.0.1:8000/api/";

  //Fetch all tasks
  Future<void> fetchTasks () async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _accessToken = sharedPreferences.getString("access");

    final url = Uri.parse("${baseUrl}tasks/");

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
        _tasks =
            data.map((item) => Task.fromJson(item)).toList();
        notifyListeners();
      } else {
        throw Exception(
            'Failed to fetch class schedules. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      print("Error fetching class schedules: $error");
    }
  }

  //Add a task
  Future<void> addTask({
    required String taskName,
    required String taskDesc,
    required DateTime scheduledDate,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required DateTime deadline,
    required String subjectCode,
  }) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _accessToken = sharedPreferences.getString("access");

    String formattedStartTime = _formatTimeOfDay(startTime);
    String formattedEndTime = _formatTimeOfDay(endTime);
    String formattedScheduledDate = DateFormat('yyyy-MM-dd').format(scheduledDate);
    String formattedDeadline = DateFormat("yyyy-MM-dd'T'HH:mm").format(deadline);

    bool isConflict = _tasks.any((schedule) =>
      schedule.scheduledDate == scheduledDate &&
      schedule.scheduledStartTime == formattedStartTime &&
      schedule.scheduledEndTime == formattedEndTime);

    if (isConflict) {
      throw Exception(
          'Task schedule conflict detected. Please modify your entry.');
    }

    bool isDuplicate = _tasks.any((schedule) =>
      schedule.taskName == taskName &&
      schedule.taskDescription == taskDesc &&
      schedule.scheduledDate == scheduledDate &&
      schedule.scheduledStartTime == formattedStartTime &&
      schedule.scheduledEndTime == formattedEndTime &&
      schedule.deadline == deadline &&
      schedule.subjectCode == subjectCode);

    if (isDuplicate) {
      throw Exception(
          'Duplicate task entry detected locally. Please modify your entry.');
    }

    final url = Uri.parse("${baseUrl}tasks/add_task/");
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'task_name': taskName,
          'task_desc': taskDesc,
          'scheduled_date': formattedScheduledDate,
          'scheduled_start_time': formattedStartTime,
          'scheduled_end_time': formattedEndTime,
          'deadline': formattedDeadline,
          'subject_code': subjectCode,
        }),
      );

      if (response.statusCode == 201) {
        final newSchedule = Task.fromJson(json.decode(response.body));
        _tasks.add(newSchedule);
        notifyListeners();
      } else if (response.statusCode == 400) {
        // Handle duplicate check from the backend
        final responseBody = json.decode(response.body);
        if (responseBody['error'] == 'Duplicate task entry detected.') {
          throw Exception('Duplicate task entry detected on the server.');
        } else {
          throw Exception('Error adding task: ${response.body}');
        }
      } else {
        throw Exception('Failed to add task: ${response.body}');
      }

    } catch (error) {
      print('Add task error: $error');
      throw Exception('Error adding task: $error');
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
}
