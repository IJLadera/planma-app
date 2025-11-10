import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:planma_app/models/schedule_entry_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ScheduleEntryProvider with ChangeNotifier {
  List<ScheduleEntry> _scheduleEntries = [];
  String? _accessToken;

  List<ScheduleEntry> get scheduleEntries => _scheduleEntries;
  String? get accessToken => _accessToken;

  // Base API URL - adjust this to match your backend URL
  late final String _baseApiUrl;

  // Constructor to properly initialize the base URL
  ScheduleEntryProvider() {
    // Remove trailing slash if present in API_URL
    String baseUrl =
        dotenv.env['API_URL'] ?? 'https://planma-app-production.up.railway.app';
    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }
    _baseApiUrl = '$baseUrl/api';
  }

  Future<Map<String, dynamic>?> fetchFilteredEntries(
      String categoryType, String referenceId) async {
    final url = Uri.parse(
        '$_baseApiUrl/schedule/filter/?category_type=$categoryType&reference_id=$referenceId');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $_accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      debugPrint("Failed to fetch filtered entries: ${response.body}");
      return null;
    }
  }

  Future<void> fetchScheduleEntries() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _accessToken = sharedPreferences.getString("access");

    final url = Uri.parse("$_baseApiUrl/schedule/");

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $_accessToken',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _scheduleEntries =
            data.map((item) => ScheduleEntry.fromJson(item)).toList();
        notifyListeners();
      } else {
        throw Exception(
            'Failed to fetch schedule entries. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      print("Error fetching schedule entries: $error");
    }
  }

  Future<List<dynamic>?> fetchBulkFilteredEntries(
      List<Map<String, dynamic>> filters) async {
    final url = Uri.parse("$_baseApiUrl/schedule/bulk_filter/");
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $_accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'filters': filters}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      debugPrint("Failed to fetch bulk filtered entries: ${response.body}");
      return null;
    }
  }

  void resetState() {
    _scheduleEntries = [];
    notifyListeners();
  }
}
