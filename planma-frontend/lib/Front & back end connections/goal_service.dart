import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:planma_app/Providers/user_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

//create events 


class GoalCreate {
  final String baseUrl ="http://127.0.0.1:8000/api";


  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    
    return prefs.getString("access");
  }


  Future<Map<String, dynamic>?> eventCT({
    required String eventname,
    required String eventdesc,
    required String location,
    required String scheduledate,
    required String starttime,
    required String endtime,
    required String eventtype,
    required String studentID,


  }) async {
    final url = "$baseUrl/creategoals/";
    final String? token = await getToken();
    print(token);
    print (eventname);
    print (eventdesc);
    print (location);
    print (scheduledate);
    print (starttime);
    print (endtime);
    print (eventtype);



    if (token == null) {
      print("No token found! Please log in first.");
      return {"error": "Authentication token not available"};
    }

      try {
        final response = await http.post(
          Uri.parse(url),
          headers: { 
          "Authorization": "Bearer $token"
          },

          body: {
            "event_name": eventname,
            "event_desc": eventdesc,
            "location": location,
            "scheduled_date": scheduledate,
            "scheduled_start_time": starttime,
            "scheduled_end_time": endtime,
            "event_type": eventtype,
            "student_id": studentID,
          },
        );

      if (response.statusCode == 201) {

        return jsonDecode(response.body);
      } else {
          print(jsonDecode(response.body));
        return {
          "error": jsonDecode(response.body)["detail"] ??
                "Failed to create Events"
        };
      }
    } catch (e) {
      print("error An error occurred. Please try again later:$e.");
        // Handle any errors that occurred during the request
        return {"error": "An error occurred. Please try again later:$e."};
    }
  }
}
