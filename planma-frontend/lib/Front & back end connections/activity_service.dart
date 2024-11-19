import 'dart:convert';
import 'package:http/http.dart' as http;


class ActivityCreate {
  final String baseUrl ="http://127.0.0.1:8000/api/";

  Future<Map<String, dynamic>?> activityCT({
    required String eventname,
    required String eventdesc,
    required String location,
    required String scheduledate,
    required String starttime,
    required String endtime,
    required String eventtype,
  }) async {
    final url = "${baseUrl}createactivity/";

      try {
        final response = await http.post(
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
                "Failed to create Activity"
        };
      }
    } catch (e) {
      print("error An error occurred. Please try again later:$e.");
        // Handle any errors that occurred during the request
        return {"error": "An error occurred. Please try again later:$e."};
    }
  }
}

class ActivityEdit {
  final String baseUrl ="http://127.0.0.1:8000/api/";

  Future<Map<String, dynamic>?> activityUP({
    required String eventname,
    required String eventdesc,
    required String location,
    required String scheduledate,
    required String starttime,
    required String endtime,
    required String eventtype,
  }) async {
    final url = "${baseUrl}updateactivity/";

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
                "Failed to Update Activity"
        };
      }
    } catch (e) {
      print("error An error occurred. Please try again later:$e.");
        // Handle any errors that occurred during the request
        return {"error": "An error occurred. Please try again later:$e."};
    }
  }
}



class ActivityView {
  final String baseUrl ="http://127.0.0.1:8000/api/";

  Future<Map<String, dynamic>?> activityVW({
    required String eventname,
    required String eventdesc,
    required String location,
    required String scheduledate,
    required String starttime,
    required String endtime,
    required String eventtype,
  }) async {
    final url = "${baseUrl}activities/";

      try {
        final response = await http.post(
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
                "Failed to View Activities"
        };
      }
    } catch (e) {
      print("error An error occurred. Please try again later:$e.");
        // Handle any errors that occurred during the request
        return {"error": "An error occurred. Please try again later:$e."};
    }
  }
}




class ActivityDelete {
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
    final url = "${baseUrl}deleteactivity/";

      try {
        final response = await http.delete(
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
                "Failed to delete activity"
        };
      }
    } catch (e) {
      print("error An error occurred. Please try again later:$e.");
        // Handle any errors that occurred during the request
        return {"error": "An error occurred. Please try again later:$e."};
    }
  }
}