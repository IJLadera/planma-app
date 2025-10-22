import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:planma_app/Providers/activity_provider.dart';
import 'package:planma_app/Providers/class_schedule_provider.dart';
import 'package:planma_app/Providers/events_provider.dart';
import 'package:planma_app/Providers/semester_provider.dart';
import 'package:planma_app/Providers/task_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthLogout {
  String? _accessToken;
  String? get accessToken => _accessToken;

  // Base API URL - adjust this to match your backend URL
  late final String _baseApiUrl;

  // Constructor to properly initialize the base URL
  AuthLogout() {
    // Remove trailing slash if present in API_URL
    String baseUrl =
        dotenv.env['API_URL'] ?? 'http://planma-app-production.up.railway.app';
    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }
    _baseApiUrl = baseUrl;
  }

  Future<void> logOut(BuildContext context) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    // final semesterProvider = Provider.of<SemesterProvider>(context, listen: false);
    // final classScheduleProvider = Provider.of<ClassScheduleProvider>(context, listen: false);

    // Remove Tokens
    await sharedPreferences.remove("access");
    await sharedPreferences.remove("refresh");

    //Clear Providers
    Provider.of<SemesterProvider>(context, listen: false).resetState();
    Provider.of<ClassScheduleProvider>(context, listen: false).resetState();
    Provider.of<TaskProvider>(context, listen: false).resetState();
    Provider.of<EventsProvider>(context, listen: false).resetState();
    Provider.of<ActivityProvider>(context, listen: false).resetState();

    print("Logout successful");

    // _accessToken = sharedPreferences.getString("access");

    // final url = Uri.parse("$_baseApiUrl/auth/token/logout/");

    // final response = await http.post(
    //   url,
    //   headers: {
    //     'Authorization': 'Bearer $_accessToken',
    //   },
    // );

    // if (response.statusCode == 204) {
    //   print("Logout successful");
    //   return jsonDecode(response.body);
    // } else {
    //   print("Logout failed");
    //   return {"error": "Failed to login"};
    // }
  }
}

// class AuthLogout {
//   String? _accessToken;
//   String? get accessToken => _accessToken;

//   Future<bool> logOut () async {
//     SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

//     // await sharedPreferences.remove("access");
//     // await sharedPreferences.remove("refresh");

//     // print("Logout successful");

//     _accessToken = sharedPreferences.getString("access");

//     if (_accessToken == null) {
//       print("No access token found. User already logged out.");
//       return true;
//     }

//     final url = Uri.parse("${baseUrl}auth/jwt/logout/");

//     final response = await http.post(
//       url,
//       headers: {
//         'Authorization': 'Bearer $_accessToken',
//       },
//     );

//     if (response.statusCode == 204) {
//       // Clear tokens from SharedPreferences
//       await sharedPreferences.remove("access");
//       await sharedPreferences.remove("refresh");
//       print("Logout successful");
//       return true;
//     } else {
//       print("Logout failed: ${response.statusCode}");
//       return false;
//     }
//   }
// }
