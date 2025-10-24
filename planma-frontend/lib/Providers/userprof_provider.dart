import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';
import 'package:mime/mime.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
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

  // Base API URL - adjust this to match your backend URL
  late final String _baseApiUrl;

  // Constructor to properly initialize the base URL
  UserProfileProvider() {
    // Remove trailing slash if present in API_URL
    String baseUrl =
        dotenv.env['API_URL'] ?? 'https://planma-app-production.up.railway.app';
    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }
    _baseApiUrl = '$baseUrl/api';
  }

  // Fetch user profile
  Future<void> fetchUserProfile() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _accessToken = sharedPreferences.getString("access");
    final url = Uri.parse("$_baseApiUrl/users/me/");

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
      {XFile? imageFile}) async {
    final url = Uri.parse("$_baseApiUrl/users/update_profile/");

    try {
      var request = http.MultipartRequest("PUT", url);
      request.headers['Authorization'] = 'Bearer $_accessToken';

      // Add user details as text fields
      request.fields['firstname'] = firstName;
      request.fields['lastname'] = lastName;
      request.fields['username'] = username;

      // If an image is provided, attach it as a file
      if (imageFile != null) {
        print("Uploading Image: ${imageFile.name}, Path: ${imageFile.path}");
        if (kIsWeb) {
          Uint8List? bytes = await imageFile.readAsBytes();
          String fileName =
              imageFile.name.isNotEmpty ? imageFile.name : "profile.jpg";
          request.files.add(http.MultipartFile.fromBytes(
            'profile_picture',
            bytes,
            filename: fileName,
          ));
        } else {
          if (!File(imageFile.path).existsSync()) {
            throw Exception("File does not exist: ${imageFile.path}");
          }
          request.files.add(await http.MultipartFile.fromPath(
              'profile_picture', imageFile.path));
        }
      }

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        final data = json.decode(responseData);
        print("Response Body: $responseData");

        if (data['image_url'] != null) {
          _profilePicture = data['image_url'];
        }

        _firstName = firstName;
        _lastName = lastName;
        _username = username;
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
