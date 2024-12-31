import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class SemesterProvider with ChangeNotifier {
  List<Map<String, dynamic>> _semesters = [];
  String? _accessToken;

  List<Map<String, dynamic>> get semesters => _semesters;
  String? get accessToken => _accessToken;

  final String baseUrl = "http://127.0.0.1:8000/api/";

  //Fetch all semesters
  Future<void> fetchSemesters() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _accessToken = sharedPreferences.getString("access");
    final url = Uri.parse("${baseUrl}semesters/");

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $_accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        // print("Semesters fetched: $data");
        _semesters = data.map((item) => Map<String, dynamic>.from(item)).toList();
        notifyListeners();
      } else {
        throw Exception('Failed to fetch semesters. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      print(error);
    }
  }

  //Fetch semester details
  Future<Map<String, dynamic>?> getSemesterDetails(int semesterId) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _accessToken = sharedPreferences.getString("access");

    final semesterUrl = Uri.parse("${baseUrl}semesters/$semesterId/"); // Correct URL format

    try {
      // Sending GET request to fetch the semester details
      final response = await http.get(
        semesterUrl,
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // If successful, parse the response body
        final semesterData = json.decode(response.body);
        // print("Semester details: $semesterData");

        // Return the semester data as a Map
        return semesterData;
      } else {
        // If request fails, throw an exception with error details
        throw Exception('Failed to load semester: ${response.body}');
      }
    } catch (error) {
      // Handle errors such as network issues
      print('Error fetching semester: $error');
      throw Exception('Error fetching semester: $error');
    }
  }


  //Add a semester
  Future<int> addSemester({
    required int acadYearStart,
    required int acadYearEnd,
    required String yearLevel,
    required String semester,
    required DateTime selectedStartDate,
    required DateTime selectedEndDate,
  }) async {
    if (acadYearEnd <= acadYearStart) {
      throw Exception("Academic year end must be greater than the start year.");
    }
    if (selectedStartDate.isAfter(selectedEndDate)) {
      throw Exception("Start date must be before the end date.");
    }

    final url = Uri.parse("${baseUrl}semesters/add_semester/");
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _accessToken = sharedPreferences.getString("access");

    String semesterStartDate = DateFormat('yyyy-MM-dd').format(selectedStartDate);
    String semesterEndDate = DateFormat('yyyy-MM-dd').format(selectedEndDate);

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'acad_year_start': acadYearStart,
          'acad_year_end': acadYearEnd,
          'year_level': yearLevel,
          'semester': semester,
          'sem_start_date': semesterStartDate,
          'sem_end_date': semesterEndDate,
        }),
      );

      if (response.statusCode == 201) {
        final newSemester = json.decode(response.body) as Map<String, dynamic>;
        final int newSemesterId = newSemester['semester_id'];
        _semesters.add(newSemester);
        notifyListeners();
        return newSemesterId;
      } else {
        throw Exception(
            'Failed to add semester. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      rethrow;
    }
  }

  void resetState() {
    _semesters = [];
    notifyListeners();
  }
}


