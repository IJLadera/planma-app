import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

//create events

class ActivityCreate {
  // Base API URL - adjust this to match your backend URL
  late final String _baseApiUrl;

  // Constructor to properly initialize the base URL
  ActivityCreate() {
    // Remove trailing slash if present in API_URL
    String baseUrl =
        dotenv.env['API_URL'] ?? 'https://planma-app-production.up.railway.app';
    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }
    _baseApiUrl = baseUrl;
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString("access");
  }

  Future<Map<String, dynamic>?> activityCT({
    required String activityname,
    required String activitydesc,
    required String scheduledate,
    required String starttime,
    required String endtime,
    required String status,
    required String studentID,
  }) async {
    final url = "$_baseApiUrl/createactivity/";
    final String? token = await getToken();
    print(token);
    print(activityname);
    print(activitydesc);
    print(scheduledate);
    print(starttime);
    print(status);
    print(endtime);

    if (token == null) {
      print("No token found! Please log in first.");
      return {"error": "Authentication token not available"};
    }

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Authorization": "Bearer $token"},
        body: {
          "activity_name": activityname,
          "activity_desc": activitydesc,
          "scheduled_date": scheduledate,
          "scheduled_start_time": starttime,
          "scheduled_end_time": endtime,
          "status": status,
          "student_id": studentID,
        },
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        print(jsonDecode(response.body));
        return {
          "error":
              jsonDecode(response.body)["detail"] ?? "Failed to create Activity"
        };
      }
    } catch (e) {
      print("error An error occurred. Please try again later:$e.");
      // Handle any errors that occurred during the request
      return {"error": "An error occurred. Please try again later:$e."};
    }
  }
}
