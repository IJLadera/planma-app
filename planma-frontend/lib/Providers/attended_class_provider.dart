import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:planma_app/models/attended_class_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AttendedClassProvider with ChangeNotifier {
  List<AttendedClass> _attendedClasses = [];
  String? _accessToken;

  List<AttendedClass> get attendedClasses => _attendedClasses;
  String? get accessToken => _accessToken;

  // Base API URL - adjust this to match your backend URL
  late final String _baseApiUrl;

  // Constructor to properly initialize the base URL
  AttendedClassProvider() {
    // Remove trailing slash if present in API_URL
    String baseUrl =
        dotenv.env['API_URL'] ?? 'https://planma-app-production.up.railway.app';
    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }
    _baseApiUrl = '$baseUrl/api';
  }

  // Fetch all attendance logs
  Future<void> fetchAttendedClasses(
      {String? startDate, String? endDate}) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _accessToken = sharedPreferences.getString("access");

    final url = Uri.parse(startDate != null && endDate != null
        ? "$_baseApiUrl/attended-classes/?start_date=$startDate&end_date=$endDate"
        : "$_baseApiUrl/attended-classes/");

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $_accessToken',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _attendedClasses =
            data.map((item) => AttendedClass.fromJson(item)).toList();
        notifyListeners();
      } else {
        throw Exception('Failed to load attended classes');
      }
    } catch (error) {
      rethrow;
    }
  }

  // Fetch all attendance logs per class schedule
  Future<void> fetchAttendedClassesPerClassSchedule(int classScheduleId) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _accessToken = sharedPreferences.getString("access");

    final url = Uri.parse(
        "$_baseApiUrl/attended-classes/?classsched_id=$classScheduleId");

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $_accessToken',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _attendedClasses =
            data.map((item) => AttendedClass.fromJson(item)).toList();
        notifyListeners();
      } else {
        throw Exception('Failed to load attended classes');
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> markAttendance({
    required int classScheduleId,
    required DateTime attendedDate,
    required String status,
  }) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _accessToken = sharedPreferences.getString("access");

    String formattedAttendedDate =
        DateFormat('yyyy-MM-dd').format(attendedDate);

    final url = Uri.parse("$_baseApiUrl/attended-classes/mark_attendance/");

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        },
        body: json.encode({
          'classsched_id': classScheduleId,
          'attendance_date': formattedAttendedDate,
          'status': status,
        }),
      );

      if (response.statusCode == 201) {
        final newAttendance =
            AttendedClass.fromJson(json.decode(response.body));
        _attendedClasses.add(newAttendance);
        notifyListeners();
      } else if (response.statusCode == 200) {
        // If already marked
        return;
      } else {
        throw Exception('Failed to mark attendance. ${response.statusCode}');
      }
    } catch (error) {
      rethrow;
    }
  }

  void resetState() {
    _attendedClasses = [];
    notifyListeners();
  }
}
