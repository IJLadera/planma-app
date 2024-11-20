import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:planma_app/Providers/user_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

class ReportAct {
  final String baseUrl = "http://127.0.0.1:8000/api";

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("access");
  }

  Future<List<Map<String, dynamic>>?> fetchActivities() async {
    final url = "$baseUrl/activities/";
    final String? token = await getToken();
    print(token);

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
        // Assuming the response body contains a list of events in JSON format
        final List<dynamic> activities = jsonDecode(response.body);
        return activities.map((activity) => activity as Map<String, dynamic>).toList();
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