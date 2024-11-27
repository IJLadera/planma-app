import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClassScheduleProvider with ChangeNotifier {
  List<Map<String, dynamic>> _classSchedules = [];
  String? _accessToken;

  List<Map<String, dynamic>> get classSchedules => _classSchedules;
  String? get accessToken => _accessToken;

  final String baseUrl = "http://127.0.0.1:8000/api/";

  //Fetch all class schedules
  Future<void> fetchClassSchedules() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _accessToken = sharedPreferences.getString("access");
    final url = Uri.parse("${baseUrl}class-schedules/");

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $_accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        _classSchedules =
            data.map((item) => Map<String, dynamic>.from(item)).toList();
        notifyListeners();
      } else {
        throw Exception(
            'Failed to fetch class schedules. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      print(error);
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

    final url = Uri.parse("${baseUrl}class-schedules/add_schedule/");
    String formattedStartTime = _formatTimeOfDay(startTime);
    String formattedEndTime = _formatTimeOfDay(endTime);

    print("PROV Subject Code: $subjectCode");
    print("PROV Subject Title: $subjectTitle");
    print("PROV Semester: $semesterId");
    print("PROV Days: $dayOfWeek");
    print("PROV Start Time: $startTime");
    print("PROV End Time: $endTime");
    print("PROV Room: $room");
    print("PROV Start Time 2: $formattedStartTime");
    print("PROV End Time 2: $formattedEndTime");

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
        final newSchedule = json.decode(response.body) as Map<String, dynamic>;
        _classSchedules.add(newSchedule);
        notifyListeners();
      } else {
        throw Exception(
            'Failed to add class schedule. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      rethrow;
    }
  }

  //Edit a class schedule
  Future<void> editClassSchedule({
    required int scheduleId,
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

    final url = Uri.parse("${baseUrl}class-schedules/$scheduleId/");
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
        final updatedSchedule = json.decode(response.body) as Map<String, dynamic>;
        int index = _classSchedules.indexWhere((schedule) => schedule['id'] == scheduleId);
        if (index != -1) {
          _classSchedules[index] = updatedSchedule;
          notifyListeners();
        }
      } else {
        throw Exception(
            'Failed to edit class schedule. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      rethrow;
    }
  }

  // Delete a class schedule
  Future<void> deleteClassSchedule(int scheduleId) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _accessToken = sharedPreferences.getString("access");

    final url = Uri.parse("${baseUrl}class-schedules/$scheduleId/");

    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $_accessToken',
        },
      );

      if (response.statusCode == 204) {
        _classSchedules.removeWhere((schedule) => schedule['id'] == scheduleId);
        notifyListeners();
      } else {
        throw Exception(
            'Failed to delete class schedule. Status Code: ${response.statusCode}');
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
}