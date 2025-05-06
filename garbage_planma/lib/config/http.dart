import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:planma/config/backend_options.dart';

class ApiClient {
  final String _baseApiUrl = Config().baseApiUrl;

  // Generic GET request
  Future<http.Response> get(String endpoint,
      {Map<String, String>? headers}) async {
    try {
      final url = Uri.parse('$_baseApiUrl/$endpoint');
      final response = await http.get(url, headers: headers);

      return _handleResponse(response);
    } on SocketException {
      throw Exception('No Internet connection');
    }
  }

  // Generic POST request
  Future<http.Response> post(String endpoint, Map<String, dynamic> body,
      {Map<String, String>? headers}) async {
    try {
      final url = Uri.parse('$_baseApiUrl/$endpoint');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          ...?headers, // Merge any additional headers passed in
        },
        body: jsonEncode(body),
      );

      return _handleResponse(response);
    } on SocketException {
      throw Exception('No Internet connection');
    }
  }

  // Generic PUT request
  Future<http.Response> put(String endpoint, Map<String, dynamic> body,
      {Map<String, String>? headers}) async {
    try {
      final url = Uri.parse('$_baseApiUrl/$endpoint');
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          ...?headers,
        },
        body: jsonEncode(body),
      );

      return _handleResponse(response);
    } on SocketException {
      throw Exception('No Internet connection');
    }
  }

  // Generic DELETE request
  Future<http.Response> delete(String endpoint,
      {Map<String, String>? headers}) async {
    try {
      final url = Uri.parse('$_baseApiUrl/$endpoint');
      final response = await http.delete(url, headers: headers);

      return _handleResponse(response);
    } on SocketException {
      throw Exception('No Internet connection');
    }
  }

  // Handle the response, check for successful status codes
  http.Response _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response; // Success
    } else if (response.statusCode >= 400 && response.statusCode < 500) {
      throw Exception('Client error: ${response.statusCode}');
    } else if (response.statusCode >= 500 && response.statusCode < 600) {
      throw Exception('Server error: ${response.statusCode}');
    } else {
      throw Exception('Unknown error: ${response.statusCode}');
    }
  }
}
