import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ReportAct {
  final String baseUrl = "http://127.0.0.1:8000/api";
  String? activityName;
  String? get activName => activityName;
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("access");
  }

  Future<List<Map<String, dynamic>>?> fetchActivities(carreon) async {
    final url = "$baseUrl/activities/$carreon/";
    final String? token = await getToken();
    if (token == null) {
      print("No token found! Please log in first.");
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        // Assuming the response body contains a list of activities in JSON format
        final activities = json.decode(response.body);
        activityName = activities['activity_name'];
        return fetchActivities(carreon);
      } else {
        print("Failed to fetch events: ${response.body}");
        return null;
      }
    } catch (e) {
      print("An error occurred while fetching events: $e");
      return null;
    }
  }
}