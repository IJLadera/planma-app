import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:planma_app/models/attended_events_model.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AttendedEventsProvider with ChangeNotifier {
  List<AttendedEvent> _attendedEvents = [];
  String? _accessToken;

  List<AttendedEvent> get attendedEvents => [..._attendedEvents];
  String? get accessToken => _accessToken;

  // Base API URL - adjust this to match your backend URL
  late final String _baseApiUrl;

  // Constructor to properly initialize the base URL
  AttendedEventsProvider() {
    // Remove trailing slash if present in API_URL
    String baseUrl =
        dotenv.env['API_URL'] ?? 'http://planma-app-production.up.railway.app';
    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }
    _baseApiUrl = '$baseUrl/api';
  }

  Future<void> fetchAttendedEvents({String? startDate, String? endDate}) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _accessToken = sharedPreferences.getString("access");

    final url = Uri.parse(startDate != null && endDate != null
        ? "$_baseApiUrl/attended-events/?start_date=$startDate&end_date=$endDate"
        : "$_baseApiUrl/attended-events/");

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $_accessToken',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _attendedEvents =
            data.map((item) => AttendedEvent.fromJson(item)).toList();
        notifyListeners();
      } else {
        throw Exception('Failed to load attended events');
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> markAttendance({
    required int eventId,
    required DateTime date,
    required bool hasAttended,
  }) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _accessToken = sharedPreferences.getString("access");

    String formattedScheduledDate = DateFormat('yyyy-MM-dd').format(date);

    final url = Uri.parse("$_baseApiUrl/attended-events/mark_attendance/");

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        },
        body: json.encode({
          'event_id': eventId,
          'date': formattedScheduledDate,
          'has_attended': hasAttended,
        }),
      );

      if (response.statusCode == 201) {
        final newAttendance =
            AttendedEvent.fromJson(json.decode(response.body));
        _attendedEvents.add(newAttendance);
        notifyListeners();
      } else if (response.statusCode == 200) {
        // If already marked
        return;
      } else {
        throw Exception('Failed to mark attendance');
      }
    } catch (error) {
      rethrow;
    }
  }

  void resetState() {
    _attendedEvents = [];
    notifyListeners();
  }
}
