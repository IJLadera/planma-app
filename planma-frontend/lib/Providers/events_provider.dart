import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:planma_app/models/events_model.dart'; // Import the Event model

class EventsProvider with ChangeNotifier {
  List<Event> _events = [];
  String? _accessToken;

  List<Event> get events => _events;

  Future<void> init() async {
    await fetchEventsList();
    notifyListeners();
  }

  final String baseUrl = "http://127.0.0.1:8000/api/";

  // Fetch events list
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
}