import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:planma_app/models/events_model.dart';

class EventsProvider with ChangeNotifier {
  List<Event> _upcomingEvents = [];
  List<Event> _pastEvents = [];
  List<Event> _events = [];
  String? _accessToken;

  List<Event> get upcomingEvents => _upcomingEvents;
  List<Event> get pastEvents => _pastEvents;
  List<Event> get events => _events;
  String? get accessToken => _accessToken;

  // Base API URL - adjust this to match your backend URL
  late final String _baseApiUrl;

  EventsProvider() {
    // Remove trailing slash if present in API_URL
    String baseUrl = dotenv.env['API_URL'] ??
        'http://https://planma-app-production.up.railway';
    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }
    _baseApiUrl = '$baseUrl/api';
  }

  // Fetch upcoming events list
  Future<void> fetchUpcomingEvents() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _accessToken = sharedPreferences.getString("access");

    if (_accessToken == null || _accessToken!.isEmpty) {
      print("Skipping fetchEvents: no access token");
      return;
    }

    final url = Uri.parse("$_baseApiUrl/events/upcoming_events/");

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $_accessToken',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final newEvents =
            data.map((eventJson) => Event.fromJson(eventJson)).toList();

        // Merge new events into the master list
        _events.addAll(newEvents.where((newEvent) => !_events.any(
            (existingEvent) => existingEvent.eventId == newEvent.eventId)));

        _sortEvents(); // Reorganize events
      } else {
        throw Exception(
            'Failed to fetch Events. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      print("Error fetching events: $error");
    }
  }

  // Fetch past events list
  Future<void> fetchPastEvents() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _accessToken = sharedPreferences.getString("access");

    final url = Uri.parse("$_baseApiUrl/events/past_events/");

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $_accessToken',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final newEvents =
            data.map((eventJson) => Event.fromJson(eventJson)).toList();

        // Merge new events into the master list
        _events.addAll(newEvents.where((newEvent) => !_events.any(
            (existingEvent) => existingEvent.eventId == newEvent.eventId)));

        _sortEvents(); // Reorganize events
      } else {
        throw Exception(
            'Failed to fetch Events. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      rethrow;
    }
  }

  // Delete a Event
  Future<void> deleteEvent(int eventId) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _accessToken = sharedPreferences.getString("access");

    final url = Uri.parse("$_baseApiUrl/events/$eventId/");

    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $_accessToken',
        },
      );

      if (response.statusCode == 204) {
        _events.removeWhere((event) => event.eventId == eventId);
        _sortEvents(); // Reorganize events
        notifyListeners();
      } else {
        throw Exception(
            'Failed to delete event. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      rethrow;
    }
  }

  //add a event
  Future<void> addEvent({
    required String eventName,
    required String? eventDesc,
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
    String formattedScheduledDate =
        DateFormat('yyyy-MM-dd').format(scheduledDate);
    String? normalizedDesc =
        eventDesc?.trim().isEmpty == true ? null : eventDesc;

    bool isConflict = _events.any((schedule) =>
        schedule.scheduledDate == scheduledDate &&
        schedule.scheduledStartTime == formattedStartTime &&
        schedule.scheduledEndTime == formattedEndTime);

    if (isConflict) {
      throw Exception(
          'event schedule conflict detected. Please modify your entry.');
    }

    bool isDuplicate = _events.any((schedule) =>
        schedule.eventName == eventName &&
        ((schedule.eventDesc?.trim().isEmpty == true
                ? null
                : schedule.eventDesc) ==
            normalizedDesc) &&
        schedule.scheduledDate == scheduledDate &&
        schedule.scheduledStartTime == formattedStartTime &&
        schedule.scheduledEndTime == formattedEndTime);

    if (isDuplicate) {
      throw Exception(
          'Duplicate event entry detected locally. Please modify your entry.');
    }

    final url = Uri.parse("$_baseApiUrl/events/add_event/");
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'event_name': eventName,
          'event_desc': normalizedDesc,
          'location': location,
          'scheduled_date': formattedScheduledDate,
          'scheduled_start_time': formattedStartTime,
          'scheduled_end_time': formattedEndTime,
          'event_type': eventType,
        }),
      );

      if (response.statusCode == 201) {
        final newEvent = Event.fromJson(json.decode(response.body));
        _events.add(newEvent);
        _sortEvents(); // Reorganize events
      } else if (response.statusCode == 400) {
        // Handle duplicate check from the backend
        final responseBody = json.decode(response.body);
        if (responseBody['error_type'] == 'overlap') {
          throw Exception('Scheduling overlap: ${responseBody['message']}');
        } else if (responseBody['error'] == 'Duplicate event entry detected.') {
          throw Exception('Duplicate event entry detected on the server.');
        } else {
          throw Exception('Error adding event: ${response.body}');
        }
      } else {
        throw Exception('Failed to add event: ${response.body}');
      }
    } catch (error) {
      print('Add event error: $error');
      throw Exception('Error adding event: $error');
    }
  }

  // Edit a event
  Future<void> updateEvent({
    required int eventId,
    required String eventName,
    required String? eventDesc,
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
    String formattedScheduledDate =
        DateFormat('yyyy-MM-dd').format(scheduledDate);
    String? normalizedDesc =
        eventDesc?.trim().isEmpty == true ? null : eventDesc;

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
        ((schedule.eventDesc?.trim().isEmpty == true
                ? null
                : schedule.eventDesc) ==
            normalizedDesc) &&
        schedule.scheduledDate == scheduledDate &&
        schedule.scheduledStartTime == formattedStartTime &&
        schedule.scheduledEndTime == formattedEndTime);

    if (isDuplicate) {
      throw Exception(
          'Duplicate event entry detected locally. Please modify your entry.');
    }

    final url = Uri.parse("$_baseApiUrl/events/$eventId/");

    try {
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'event_name': eventName,
          'event_desc': normalizedDesc,
          'location': location,
          'scheduled_date': formattedScheduledDate,
          'scheduled_start_time': formattedStartTime,
          'scheduled_end_time': formattedEndTime,
          'event_type': eventType,
        }),
      );

      if (response.statusCode == 200) {
        final updatedEvent = Event.fromJson(json.decode(response.body));
        final index = _events.indexWhere((event) => event.eventId == eventId);
        if (index != -1) {
          _events[index] = updatedEvent;
          _sortEvents(); // Reorganize events
        }
      } else if (response.statusCode == 400) {
        // Handle duplicate check from the backend
        final responseBody = json.decode(response.body);
        if (responseBody['error_type'] == 'overlap') {
          throw Exception('Scheduling overlap: ${responseBody['message']}');
        } else if (responseBody['error'] == 'Duplicate event entry detected.') {
          throw Exception('Duplicate event entry detected on the server.');
        } else {
          throw Exception('Error adding event: ${response.body}');
        }
      } else {
        throw Exception('Failed to update Event: ${response.body}');
      }
    } catch (error) {
      print('Update event error: $error');
      throw Exception('Error updating Event: $error');
    }
  }

  void resetState() {
    _events = [];
    _sortEvents();
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

  // Utility method to sort events if it is upcoming or past.
  void _sortEvents() {
    final now = DateTime.now();

    _upcomingEvents = _events
        .where((event) =>
            event.scheduledDate.isAfter(now) ||
            _isSameDay(event.scheduledDate, now))
        .toList();

    _pastEvents = _events
        .where((event) =>
            event.scheduledDate.isBefore(now) &&
            !_isSameDay(event.scheduledDate, now))
        .toList();

    notifyListeners();
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
