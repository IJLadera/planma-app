import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:planma_app/models/attended_events_model.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AttendedEventsProvider with ChangeNotifier {
  List<AttendedEvent> _attendedEvents = [];
  String? _accessToken;

  List<AttendedEvent> get attendedEvents => [..._attendedEvents];
  String? get accessToken => _accessToken;

  final String baseUrl = "http://127.0.0.1:8000/api/";

  Future<void> fetchAttendedEvents() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _accessToken = sharedPreferences.getString("access");

    final url = Uri.parse("${baseUrl}attended-events/");

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $_accessToken',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _attendedEvents = data.map((item) => AttendedEvent.fromJson(item)).toList();
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
    
    final url = Uri.parse("${baseUrl}attended-events/mark_attendance/");

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
        final newAttendance = AttendedEvent.fromJson(json.decode(response.body));
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
