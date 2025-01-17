import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserProfileProvider with ChangeNotifier {
  String? _firstName;
  String? _lastName;
  String? _username;
  String? _accessToken;
  String? _profilePicture;

  String? get firstName => _firstName;
  String? get lastName => _lastName;
  String? get username => _username;
  String? get accessToken => _accessToken;
  String? get profilePicture => _profilePicture;

  Future<void> init() async {
    await fetchUserProfile();
    notifyListeners();
  }

  final String baseUrl = "http://127.0.0.1:8000/api/";

  // Fetch user profile
  Future<void> fetchUserProfile() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _accessToken = sharedPreferences.getString("access");
    final url = Uri.parse("${baseUrl}users/me/");

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $_accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data.toString());
        _firstName = data['firstname'];
        _lastName = data['lastname'];
        _username = data['username'];
        _profilePicture = data['profile_picture'];
        notifyListeners();
      } else {
        throw Exception(
            'Failed to fetch profile. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      rethrow;
    }
  }

  // Update user profile
  Future<void> updateUserProfile(
      String firstName, String lastName, String username,
      {File? profilePicture}) async {
    final url = Uri.parse("${baseUrl}users/update_profile/");
    var request = http.MultipartRequest('PUT', url);

    request.headers['Authorization'] = 'Bearer $_accessToken';

    request.fields['firstname'] = firstName;
    request.fields['lastname'] = lastName;
    request.fields['username'] = username;

    if (profilePicture != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'profile_picture',
        profilePicture.path,
      ));
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _firstName = data['firstname'];
        _lastName = data['lastname'];
        _username = data['username'];
        _profilePicture = data['profile_picture'];
        notifyListeners();
      } else {
        throw Exception(
            'Failed to update profile. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      rethrow;
    }
  }
}
