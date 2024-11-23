import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:planma_app/Providers/user_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

//create events 


class EventsCreate {
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
    final url = "$baseUrl/createevents/";
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

// Viewing Events

// class EventsView {
//   final String baseUrl = "http://127.0.0.1:8000/api";

//   Future<String?> getToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString("access");
//   }

//   Future<List<Map<String, dynamic>>> fetchEvents() async {
//     final url = "$baseUrl/events/";
//     final String? token = await getToken();

//     if (token == null) {
//       print("No token found! Please log in first.");
//       throw Exception("Authentication token not available");
//     }

//     try {
//       final response = await http.get(
//         Uri.parse(url),
//         headers: {
//           "Authorization": "Bearer $token",
//         },
//       );

//       if (response.statusCode == 200) {
//         return List<Map<String, dynamic>>.from(jsonDecode(response.body));
//       } else {
//         print("Failed to fetch events: ${response.body}");
//         throw Exception("Failed to fetch events");
//       }
//     } catch (e) {
//       print("Error fetching events: $e");
//       throw Exception("An error occurred while fetching events.");
//     }
//   }
// }