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
    // Delete a Event
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


   // Edit a event
  Future<void> updateEvent({
    required int eventId,
    required String eventName,
    required String eventDesc,
    required String location,
    required DateTime scheduledDate,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required String eventType,
  }) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _accessToken = sharedPreferences.getString("access");

    String formattedStartTime = _formatTimeOfDay(startTime);
    String formattedEndTime = _formatTimeOfDay(endTime);
    String formattedScheduledDate = DateFormat('yyyy-MM-dd').format(scheduledDate);

    bool isConflict = _events.any((schedule) =>
      schedule.eventId != eventId &&
      schedule.scheduledDate == scheduledDate &&
      schedule.scheduledStartTime == formattedStartTime &&
      schedule.scheduledEndTime == formattedEndTime);

    if (isConflict) {
      throw Exception(
          'Event schedule conflict detected. Please modify your entry.');
    }

    bool isDuplicate = _events.any((schedule) =>
      schedule.eventName == eventName &&
      schedule.eventDesc == eventDesc &&
      schedule.scheduledDate == scheduledDate &&
      schedule.scheduledStartTime == formattedStartTime &&
      schedule.scheduledEndTime == formattedEndTime);

    if (isDuplicate) {
      throw Exception(
          'Duplicate event entry detected locally. Please modify your entry.');
    }

    final url = Uri.parse("${baseUrl}events/$eventId/");

    print('FROM PROVIDER:');
    print('Event Name: $eventName');
    print('Event Description: $eventDesc');
    print ('Location: $location');
    print('Scheduled Date: $formattedScheduledDate');
    print('Start Time: $formattedStartTime');
    print('End Time: $formattedEndTime');
    print ('EventType: $eventType');

    try {
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'event_name': eventName,
          'event_desc': eventDesc,
          'location': location,
          'scheduled_date': formattedScheduledDate,
          'scheduled_start_time': formattedStartTime,
          'scheduled_end_time': formattedEndTime,
          'event_type': eventType,
        }),
      );

      if (response.statusCode == 200) {
        final updatedSchedule = Event.fromJson(json.decode(response.body));
        final index = _events
            .indexWhere((schedule) => schedule.eventId == eventId);
        if (index != -1) {
          _events[index] = updatedSchedule;
          notifyListeners();
        }
      } else if (response.statusCode == 400) {
        // Handle duplicate check from the backend
        final responseBody = json.decode(response.body);
        if (responseBody['error'] == 'Duplicate event entry detected.') {
          throw Exception('Duplicate Event entry detected on the server.');
        } else {
          throw Exception('Error updating Event: ${response.body}');
        }
      } else {
        throw Exception('Failed to update Event: ${response.body}');
      }
    } catch (error) {
      print('Update event error: $error');
      throw Exception('Error updating Event: $error');
    }
  }

  
}

