import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:planma_app/models/subjects_model.dart';
import 'package:planma_app/models/tasks_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _pendingTasks = [];
  List<Task> _completedTasks = [];
  List<Task> _tasks = [];
  String? _accessToken;

  List<Task> get pendingTasks => _pendingTasks;
  List<Task> get completedTasks => _completedTasks;
  List<Task> get tasks => _tasks;
  String? get accessToken => _accessToken;

  // Base API URL - adjust this to match your backend URL
  late final String _baseApiUrl;

  // Constructor to properly initialize the base URL
  TaskProvider() {
    // Remove trailing slash if present in API_URL
    String baseUrl =
        dotenv.env['API_URL'] ?? 'https://planma-app-production.up.railway.app';
    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }
    _baseApiUrl = '$baseUrl/api';
  }

  // Fetch all tasks
  Future<void> fetchTasks({String? startDate, String? endDate}) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _accessToken = sharedPreferences.getString("access");

    final url = Uri.parse(
        "$_baseApiUrl/tasks/?start_date=$startDate&end_date=$endDate");

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $_accessToken',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        _tasks = data.map((item) => Task.fromJson(item)).toList();
        notifyListeners();
      } else {
        throw Exception(
            'Failed to fetch tasks. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      print("Error fetching tasks: $error");
    }
  }

  // Fetch pending tasks list
  Future<void> fetchPendingTasks() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _accessToken = sharedPreferences.getString("access");

    if (_accessToken == null || _accessToken!.isEmpty) {
      print("Skipping fetchTasks: no access token");
      return;
    }

    final url = Uri.parse("$_baseApiUrl/tasks/pending_tasks/");

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $_accessToken',
        },
      );

      print("STATUS CODE: ${response.statusCode}");
      print("BODY: ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final newTasks = data.map((item) => Task.fromJson(item)).toList();

        // Merge new tasks into the master list
        _tasks.addAll(newTasks.where((newTask) => !_tasks
            .any((existingTask) => existingTask.taskId == newTask.taskId)));

        _sortTasks(); // Reorganize tasks
      } else {
        throw Exception(
            'Failed to fetch tasks. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      print("Error fetching tasks: $error");
    }
  }

  //Fetch completed tasks list
  Future<void> fetchCompletedTasks() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _accessToken = sharedPreferences.getString("access");

    final url = Uri.parse("$_baseApiUrl/tasks/completed_tasks/");

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $_accessToken',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final newTasks = data.map((item) => Task.fromJson(item)).toList();

        //Merge new tasks into the master list
        _tasks.addAll(newTasks.where((newTask) => !_tasks
            .any((existingTask) => existingTask.taskId == newTask.taskId)));

        _sortTasks(); // Reorganize tasks
      } else {
        throw Exception(
            'Failed to fetch tasks. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      print("Error fetching tasks: $error");
    }
  }

  // Update task status dynamically
  void updateTaskStatus(int taskId, String newStatus) {
    // Find the task in the pending list
    final taskIndex = _pendingTasks.indexWhere((task) => task.taskId == taskId);
    if (taskIndex != -1) {
      final task = _pendingTasks[taskIndex];
      task.status = newStatus;

      // Move task from pending to completed if status is "Completed"
      if (newStatus == "Completed") {
        _completedTasks.add(task);
        _pendingTasks.removeAt(taskIndex);
      }

      notifyListeners();
    }
  }

  // Add a task
  Future<void> addTask({
    required String taskName,
    required String? taskDesc,
    required DateTime scheduledDate,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required DateTime deadline,
    required Subject subject,
  }) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _accessToken = sharedPreferences.getString("access");

    String formattedStartTime = _formatTimeOfDay(startTime);
    String formattedEndTime = _formatTimeOfDay(endTime);
    String formattedScheduledDate =
        DateFormat('yyyy-MM-dd').format(scheduledDate);
    String formattedDeadline =
        DateFormat("yyyy-MM-dd'T'HH:mm").format(deadline);
    String? normalizedDesc = taskDesc?.trim().isEmpty == true ? null : taskDesc;

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
        ((schedule.taskDescription?.trim().isEmpty == true
                ? null
                : schedule.taskDescription) ==
            normalizedDesc) &&
        schedule.scheduledDate == scheduledDate &&
        schedule.scheduledStartTime == formattedStartTime &&
        schedule.scheduledEndTime == formattedEndTime &&
        schedule.deadline == deadline &&
        schedule.subject?.subjectId == subject.subjectId);

    if (isDuplicate) {
      throw Exception(
          'Duplicate task entry detected locally. Please modify your entry.');
    }

    final url = Uri.parse("$_baseApiUrl/tasks/add_task/");
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'task_name': taskName,
          'task_desc': normalizedDesc,
          'scheduled_date': formattedScheduledDate,
          'scheduled_start_time': formattedStartTime,
          'scheduled_end_time': formattedEndTime,
          'deadline': formattedDeadline,
          'subject_id': subject.subjectId,
        }),
      );

      if (response.statusCode == 201) {
        final newSchedule = Task.fromJson(json.decode(response.body));
        _tasks.add(newSchedule);
        _sortTasks();
      } else if (response.statusCode == 400) {
        // Handle duplicate check from the backend
        final responseBody = json.decode(response.body);
        if (responseBody['error_type'] == 'overlap') {
          throw Exception('Scheduling overlap: ${responseBody['message']}');
        } else if (responseBody['error'] == 'Duplicate task entry detected.') {
          throw Exception('Duplicate task entry detected on the server.');
        } else {
          throw Exception('Error adding task: ${response.body}');
        }
      } else {
        throw Exception('Failed to add task: ${response.body}');
      }
    } catch (error) {
      print(error);
      throw Exception('sError adding task: $error');
    }
  }

  // Edit a task
  Future<void> updateTask({
    required int taskId,
    required String taskName,
    required String? taskDesc,
    required DateTime scheduledDate,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required DateTime deadline,
    required Subject subject,
  }) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _accessToken = sharedPreferences.getString("access");

    String formattedStartTime = _formatTimeOfDay(startTime);
    String formattedEndTime = _formatTimeOfDay(endTime);
    String formattedScheduledDate =
        DateFormat('yyyy-MM-dd').format(scheduledDate);
    String formattedDeadline =
        DateFormat("yyyy-MM-dd'T'HH:mm").format(deadline);
    String? normalizedDesc = taskDesc?.trim().isEmpty == true ? null : taskDesc;

    bool isConflict = _tasks.any((schedule) =>
        schedule.taskId != taskId &&
        schedule.scheduledDate == scheduledDate &&
        schedule.scheduledStartTime == formattedStartTime &&
        schedule.scheduledEndTime == formattedEndTime);

    if (isConflict) {
      throw Exception(
          'Task schedule conflict detected. Please modify your entry.');
    }

    bool isDuplicate = _tasks.any((schedule) =>
        schedule.taskName == taskName &&
        ((schedule.taskDescription?.trim().isEmpty == true
                ? null
                : schedule.taskDescription) ==
            normalizedDesc) &&
        schedule.scheduledDate == scheduledDate &&
        schedule.scheduledStartTime == formattedStartTime &&
        schedule.scheduledEndTime == formattedEndTime &&
        schedule.deadline == deadline &&
        schedule.subject?.subjectId == subject.subjectId);

    if (isDuplicate) {
      throw Exception(
          'Duplicate task entry detected locally. Please modify your entry.');
    }

    final url = Uri.parse("$_baseApiUrl/tasks/$taskId/");

    try {
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'task_name': taskName,
          'task_desc': normalizedDesc,
          'scheduled_date': formattedScheduledDate,
          'scheduled_start_time': formattedStartTime,
          'scheduled_end_time': formattedEndTime,
          'deadline': formattedDeadline,
          'subject_id': subject.subjectId,
        }),
      );

      if (response.statusCode == 200) {
        final updatedSchedule = Task.fromJson(json.decode(response.body));
        final index =
            _tasks.indexWhere((schedule) => schedule.taskId == taskId);
        if (index != -1) {
          _tasks[index] = updatedSchedule;
          _sortTasks();
        }
      } else if (response.statusCode == 400) {
        // Handle duplicate check from the backend
        final responseBody = json.decode(response.body);
        if (responseBody['error_type'] == 'overlap') {
          throw Exception('Scheduling overlap: ${responseBody['message']}');
        } else if (responseBody['error'] == 'Duplicate task entry detected.') {
          throw Exception('Duplicate task entry detected on the server.');
        } else {
          throw Exception('Error adding task: ${response.body}');
        }
      } else {
        throw Exception('Failed to update task: ${response.body}');
      }
    } catch (error) {
      print(error);
      throw Exception('Error updating task: $error');
    }
  }

  // Delete a task
  Future<void> deleteTask(int taskId) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _accessToken = sharedPreferences.getString("access");

    final url = Uri.parse("$_baseApiUrl/tasks/$taskId/");

    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $_accessToken',
        },
      );

      if (response.statusCode == 204) {
        _tasks.removeWhere((schedule) => schedule.taskId == taskId);
        _sortTasks();
        notifyListeners();
      } else {
        throw Exception(
            'Failed to delete task. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      rethrow;
    }
  }

  void resetState() {
    _tasks = [];
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

  // Utility method to sort tasks if it is pending or completed.
  void _sortTasks() {
    _pendingTasks = _tasks.where((task) => task.status == 'Pending').toList();

    _completedTasks =
        _tasks.where((task) => task.status == 'Completed').toList();

    notifyListeners();
  }

  Future<int> fetchTaskCount({String? startDate, String? endDate}) async {
    await fetchTasks(startDate: startDate, endDate: endDate);
    return _tasks.length;
  }
}
