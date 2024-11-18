import 'dart:convert';
import 'package:http/http.dart' as http;


class EventsCreate {
  final String baseUrl ="http://127.0.0.1:8000/api/";

  Future<Map<String, dynamic>?> eventCT({
    required String eventname,
    required String eventdesc,
    required String location,
    required String scheduledate,
    required String starttime,
    required String endtime,
    required String eventtype,
  }) async {
    final url = "${baseUrl}createevents/";

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


