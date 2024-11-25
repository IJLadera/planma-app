import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EventsProvider with ChangeNotifier {
  String? _eventName;
  String? _eventDesc;
  String? _location;
  String? _date;
  String? _time;
  String? _eventType;
  String? _accessToken;

  String? get eventName => _eventName;
  String? get eventDesc => _eventDesc;
  String? get location => _location;
  String? get date => _date;
  String? get time => _time;
  String? get eventType => _eventType;
  String? get accessToken => _accessToken;

  Future<void> init() async {
    await fetchEventsList();
    notifyListeners();
  }

  // void updateToken (String token) {
  //   _token = token;
  //   notifyListeners();
  // }

  final String baseUrl = "http://127.0.0.1:8000/api/";

  //Fetch user profile
  Future<void> fetchEventsList() async {
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
        final data = json.decode(response.body);
        print(data.toString());
        _eventName = data['event_name'];
        _eventDesc = data['event_desc'];
        _location = data['location'];
        _date = data['scheduled_date'];
        _time = data['scheduled_start_time''scheduled_end_time'];
        _eventType = data['event_type'];
        notifyListeners();
      } else {
        throw Exception('Failed to fetch Events. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      rethrow;
    }
  }

  //Update user profile
  Future<void> updateEventsList(
    String eventName, 
    String eventDesc, 
    String location,
    String date,
    String time,
    String eventType
    ) async {
    final url = Uri.parse("${baseUrl}updateevent/");

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
          'scheduled_date': date,
          'scheduled_start_time''scheduled_end_time': time,
          'event_type': eventType,
        }),
      );

      if (response.statusCode == 200) {
        _eventName = eventName;
        _eventDesc = eventDesc;
        _location = location;
        _date = date;
        _time = time;
        _eventType = eventType;
        notifyListeners();
      } else {
        throw Exception('Failed to fetch events. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      rethrow;
    }
  }
}
