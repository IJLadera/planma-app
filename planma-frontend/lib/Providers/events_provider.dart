import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:planma_app/models/events_model.dart'; // Import the Event model


class EventsProvider with ChangeNotifier {
  List<Event> _events = [];
  String? _accessToken;

  List<Event> get events => _events;
  String? get accessToken => _accessToken;

  

  final String baseUrl = "http://127.0.0.1:8000/api/";

  // Fetch events list
  Future<void> fetchEvents() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _accessToken = sharedPreferences.getString("access");
    final url = Uri.parse("${baseUrl}events/");
    
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $_accessToken',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _events = data.map((eventJson) => Event.fromJson(eventJson)).toList();
        notifyListeners();
      } else {
        throw Exception('Failed to fetch Events. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      rethrow;
    }
  }
    // Delete a task
  Future<void> deleteEvent(int eventId) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _accessToken = sharedPreferences.getString("access");

    final url = Uri.parse("${baseUrl}events/$eventId/");

    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $_accessToken',
        },
      );

      if (response.statusCode == 204) {
        _events
            .removeWhere((schedule) => schedule.eventId == eventId);
        notifyListeners();
      } else {
        throw Exception(
            'Failed to delete event. Status Code: ${response.statusCode}');
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

