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


// Edit Events

class EventsEdit {
  final String baseUrl ="http://127.0.0.1:8000/api/";

  Future<Map<String, dynamic>?> eventUP({
    required String eventname,
    required String eventdesc,
    required String location,
    required String scheduledate,
    required String starttime,
    required String endtime,
    required String eventtype,
  }) async {
    final url = "${baseUrl}updateevent/";

      try {
        final response = await http.put(
          Uri.parse(url),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "eventname": eventname,
            "eventdesc": eventdesc,
            "location": location,
            "scheduledate": scheduledate,
            "starttime": starttime,
            "endtime": endtime,
            "eventtype": eventtype,
          }),
        );

      if (response.statusCode == 201) {

        return jsonDecode(response.body);
      } else {

        return {
          "error": jsonDecode(response.body)["detail"] ??
                "Failed to Update Events"
        };
      }
    } catch (e) {
      print("error An error occurred. Please try again later:$e.");
        // Handle any errors that occurred during the request
        return {"error": "An error occurred. Please try again later:$e."};
    }
  }
}

// for viewig created events

class EventsView {
  final String baseUrl = "http://127.0.0.1:8000/api";

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("access");
  }

  Future<List<Map<String, dynamic>>?> fetchEvents() async {
    final url = "$baseUrl/events/";
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
        // Assuming the response body contains a list of events in JSON format
        final List<dynamic> events = jsonDecode(response.body);
        return events.map((event) => event as Map<String, dynamic>).toList();
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


//for deleting events that has been created

class EventsDelete {
  final String baseUrl ="http://127.0.0.1:8000/api/";

  Future<Map<String, dynamic>?> eventDEL({
    required String eventname,
    required String eventdesc,
    required String location,
    required String scheduledate,
    required String starttime,
    required String endtime,
    required String eventtype,
  }) async {
    final url = "${baseUrl}deleteevent/";

      try {
        final response = await http.delete(
          Uri.parse(url),
          headers: {"Content-Type": "application/json"},
          // body: jsonEncode({
          //   "eventname": eventname,
          //   "eventdesc": eventdesc,
          //   "location": location,
          //   "scheduledate": scheduledate,
          //   "starttime": starttime,
          //   "endtime": endtime,
          //   "eventtype": eventtype,
          // }),
        );

      if (response.statusCode == 201) {

        return jsonDecode(response.body);
      } else {

        return {
          "error": jsonDecode(response.body)["detail"] ??
                "Failed to Update Events"
        };
      }
    } catch (e) {
      print("error An error occurred. Please try again later:$e.");
        // Handle any errors that occurred during the request
        return {"error": "An error occurred. Please try again later:$e."};
    }
  }
}