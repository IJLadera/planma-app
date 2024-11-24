import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class SemesterProvider with ChangeNotifier {
  List<Map<String, dynamic>> _semesters = [];
  // Map<String, dynamic>? _selectedSemester;
  String? _accessToken;

  List<Map<String, dynamic>> get semesters => _semesters;
  // Map<String, dynamic>? get selectedSemester => _selectedSemester;
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
        _semesters = data.map((item) => Map<String, dynamic>.from(item)).toList();
        notifyListeners();
      } else {
        throw Exception('Failed to fetch semesters. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      rethrow;
    }
  }

  // Add a semester
  Future<void> addSemester({
    required int acadYearStart,
    required int acadYearEnd,
    required String yearLevel,
    required String semester,
    required DateTime selectedStartDate,
    required DateTime selectedEndDate,
  }) async {
    final url = Uri.parse("${baseUrl}semesters/");
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
        // Parse the response body to ensure consistent data format
        final newSemester = json.decode(response.body) as Map<String, dynamic>;
        _semesters.add(newSemester);
        notifyListeners();
      } else {
        throw Exception('Failed to add semester. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      rethrow;
    }
  }

  // //Set the selected semester
  // void selectSemester(Map<String, dynamic> semester) {
  //   _selectedSemester = semester;
  //   notifyListeners();
  // }
}
