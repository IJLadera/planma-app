// lib/core/network/api_client.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiClient {
  final String _baseUrl = dotenv.env['API_URL'] ?? 'http://localhost:8000/api';

  ApiClient();

  Future<dynamic> get(String endpoint, {Map<String, String>? headers}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/$endpoint'),
      headers: headers,
    );

    return _processResponse(response);
  }

  Future<dynamic> post(String endpoint, dynamic data,
      {Map<String, String>? headers}) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        ...?headers,
      },
      body: jsonEncode(data),
    );

    return _processResponse(response);
  }

  dynamic _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    } else {
      throw Exception('API Error: ${response.statusCode} - ${response.body}');
    }
  }
}
