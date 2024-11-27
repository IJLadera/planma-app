import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ActivityProvider with ChangeNotifier {
  String? _activityName;
  String? _activityDesc;
  String? _date;
  String? _time;
  String? _status;
  String? _accessToken;

  String? get activityName => _activityName;
  String? get activityDesc => _activityDesc;
  String? get date => _date;
  String? get time => _time;
  String? get status => _status;
  String? get accessToken => _accessToken;

  Future<void> init() async {
    await fetchActivitiesList();
    notifyListeners();
  }

  // void updateToken (String token) {
  //   _token = token;
  //   notifyListeners();
  // }

  final String baseUrl = "http://127.0.0.1:8000/api/";

  //Fetch events list
  Future<void> fetchActivitiesList() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _accessToken = sharedPreferences.getString("access");
    final url = Uri.parse("${baseUrl}activities/");
    
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
        _activityName = data['activity_name'];
        _activityDesc = data['activity_desc'];
        _date = data['scheduled_date'];
        _time = data['scheduled_start_time''scheduled_end_time'];
        _status = data['status'];
        notifyListeners();
      } else {
        throw Exception('Failed to fetch Events. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      rethrow;
    }
  }
}
