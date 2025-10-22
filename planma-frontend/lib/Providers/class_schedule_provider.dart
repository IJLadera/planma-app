import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:planma_app/Providers/semester_provider.dart';
import 'package:planma_app/models/class_schedules_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/subjects_model.dart';

class ClassScheduleProvider with ChangeNotifier {
  List<ClassSchedule> _classSchedules = [];
  List<Subject> subjects = [];
  Subject? _selectedSubject;
  String? _accessToken;
  int? _activeSemesterId;

  List<ClassSchedule> get classSchedules => _classSchedules;
  Subject? get selectedSubject => _selectedSubject;
  String? get accessToken => _accessToken;
  int? get activeSemesterId => _activeSemesterId;

  set activeSemesterId(int? value) {
    _activeSemesterId = value;
    notifyListeners();
  }

  // Base API URL - adjust this to match your backend URL
  late final String _baseApiUrl;

  // Constructor to properly initialize the base URL
  ClassScheduleProvider() {
    // Remove trailing slash if present in API_URL
    String baseUrl =
        dotenv.env['API_URL'] ?? 'https://planma-app-production.up.railway.app';
    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }
    _baseApiUrl = '$baseUrl/api';
  }

  //Fetch all subjects
  Future<void> fetchSubjects(SemesterProvider semesterProvider) async {
    // Fetch semesters if not already loaded
    if (semesterProvider.semesters.isEmpty) {
      await semesterProvider.fetchSemesters();
    }

    if (semesterProvider.semesters.isEmpty) {
      throw Exception("No semesters available. Cannot fetch subjects.");
    }

    // Determine the current semester dynamically
    DateTime currentDate = DateTime.now();
    final activeSemester = semesterProvider.semesters.firstWhere(
      (semester) {
        DateTime startDate = DateTime.parse(semester['sem_start_date']);
        DateTime endDate = DateTime.parse(semester['sem_end_date']);
        return currentDate.isAfter(startDate) && currentDate.isBefore(endDate);
      },
      orElse: () {
        // No active semester; fallback to the last active semester
        print(
            "No active semester found. Attempting to use the last active semester.");
        semesterProvider.semesters.sort((a, b) {
          DateTime aEndDate = DateTime.parse(a['sem_end_date']);
          DateTime bEndDate = DateTime.parse(b['sem_end_date']);
          return bEndDate.compareTo(aEndDate); // Sort descending by end date
        });

        for (var semester in semesterProvider.semesters) {
          DateTime endDate = DateTime.parse(semester['sem_end_date']);
          if (currentDate.isAfter(endDate)) {
            return semester;
          }
        }

        // If no past semester exists, return the first semester as fallback
        return semesterProvider.semesters.last;
      },
    );

    _activeSemesterId = activeSemester['semester_id'];
    print("Active semester Id: $_activeSemesterId");

    // Fetch subjects for the active semester
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _accessToken = sharedPreferences.getString("access");
    final url =
        Uri.parse("$_baseApiUrl/subjects/?semester_id=$_activeSemesterId");

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $_accessToken',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        subjects = data.map((item) => Subject.fromJson(item)).toList();
        notifyListeners();
      } else {
        throw Exception('Error fetching subjects');
      }
    } catch (error) {
      print('Error fetching subjects: $error');
      throw Exception('Error fetching subjects: $error');
    }
  }

  //Fetch existing subject details
  Future<void> fetchSubjectDetails(String subjectCode) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _accessToken = sharedPreferences.getString("access");
    final url = Uri.parse("$_baseApiUrl/subjects/$subjectCode/");

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $_accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _selectedSubject = Subject.fromJson(data);
        notifyListeners();
      } else if (response.statusCode == 404) {
        _selectedSubject = null;
        notifyListeners();
        print('Subject not found');
      } else {
        throw Exception('Error fetching subject details');
      }
    } catch (error) {
      print('Error fetching subject: $error');
      throw Exception('Error fetching subject details: $error');
    }
  }

  //Fetch all class schedules
  Future<void> fetchClassSchedules({int? selectedSemesterId}) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _accessToken = sharedPreferences.getString("access");

    // Ensure semester_id is provided
    if (selectedSemesterId == null) {
      print("Error: Semester ID is required.");
      return;
    }

    // Construct the URL with semester_id
    final url = Uri.parse(
        "$_baseApiUrl/class-schedules/?semester_id=$selectedSemesterId");

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $_accessToken',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _classSchedules =
            data.map((item) => ClassSchedule.fromJson(item)).toList();
        notifyListeners();
      } else {
        throw Exception(
            'Failed to fetch class schedules. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      print("Error fetching class schedules: $error");
    }
  }

  //Add a class schedule
  Future<void> addClassScheduleWithSubject({
    required String subjectCode,
    required String subjectTitle,
    required int semesterId,
    required String dayOfWeek,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required String room,
  }) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _accessToken = sharedPreferences.getString("access");

    String formattedStartTime = _formatTimeOfDay(startTime);
    String formattedEndTime = _formatTimeOfDay(endTime);

    // Check for duplicates locally
    bool isDuplicate = _classSchedules.any((schedule) =>
        schedule.subjectCode == subjectCode &&
        schedule.dayOfWeek == dayOfWeek &&
        schedule.scheduledStartTime == formattedStartTime &&
        schedule.scheduledEndTime == formattedEndTime &&
        schedule.room == room);

    if (isDuplicate) {
      throw Exception(
          'Duplicate schedule detected locally. Please modify your entry.');
    }

    final url = Uri.parse("$_baseApiUrl/class-schedules/add_schedule/");
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'subject_code': subjectCode,
          'subject_title': subjectTitle,
          'semester_id': semesterId,
          'day_of_week': dayOfWeek,
          'scheduled_start_time': formattedStartTime,
          'scheduled_end_time': formattedEndTime,
          'room': room,
        }),
      );

      if (response.statusCode == 201) {
        print("Class schedule added successfully.");
        final newSchedule = ClassSchedule.fromJson(json.decode(response.body));
        _classSchedules.add(newSchedule);
        notifyListeners();
      } else if (response.statusCode == 400) {
        // Handle duplicate check from the backend
        final responseBody = json.decode(response.body);
        if (responseBody['error'] == 'Duplicate schedule entry detected.') {
          throw Exception('Duplicate schedule detected on the server.');
        } else {
          throw Exception('Error adding schedule: ${response.body}');
        }
      } else {
        throw Exception('Failed to add schedule: ${response.body}');
      }
    } catch (error) {
      print('Add schedule error: $error');
      throw Exception('Error adding schedule: $error');
    }
  }

  //Edit a class schedule
  Future<void> updateClassSchedule({
    required int classschedId,
    required String subjectCode,
    required String subjectTitle,
    required int semesterId,
    required String dayOfWeek,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required String room,
  }) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _accessToken = sharedPreferences.getString("access");

    final url = Uri.parse("$_baseApiUrl/class-schedules/$classschedId/");
    String formattedStartTime = _formatTimeOfDay(startTime);
    String formattedEndTime = _formatTimeOfDay(endTime);

    try {
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'subject_code': subjectCode,
          'subject_title': subjectTitle,
          'semester_id': semesterId,
          'day_of_week': dayOfWeek,
          'scheduled_start_time': formattedStartTime,
          'scheduled_end_time': formattedEndTime,
          'room': room,
        }),
      );

      if (response.statusCode == 200) {
        final updatedSchedule =
            ClassSchedule.fromJson(json.decode(response.body));
        final index = _classSchedules
            .indexWhere((schedule) => schedule.classschedId == classschedId);
        if (index != -1) {
          _classSchedules[index] = updatedSchedule;
          notifyListeners();
        }
      } else {
        throw Exception('Failed to update class schedule: ${response.body}');
      }
    } catch (error) {
      print('Update schedule error: $error');
      throw Exception('Error updating schedule: $error');
    }
  }

  // Delete a class schedule
  Future<void> deleteClassSchedule(int classschedId) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _accessToken = sharedPreferences.getString("access");

    final url = Uri.parse("$_baseApiUrl/class-schedules/$classschedId/");

    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $_accessToken',
        },
      );

      if (response.statusCode == 204) {
        _classSchedules
            .removeWhere((schedule) => schedule.classschedId == classschedId);
        notifyListeners();
      } else {
        throw Exception(
            'Failed to delete class schedule. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      rethrow;
    }
  }

  void resetState() {
    _classSchedules = [];
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
}
