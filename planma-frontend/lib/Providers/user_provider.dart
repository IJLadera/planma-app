import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart'; // For picking image
import 'package:http/http.dart' as http; // For HTTP requests
import 'dart:io'; // For handling file

class UserProvider extends ChangeNotifier {
  String? _userName;
  String? _accessToken;
  String? _refreshToken;
  String? _profilePicture;

  String? get userName => _userName;
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  String? get profilePicture => _profilePicture;

  // Initialize user data
  void init({
    required String userName,
    required String accessToken,
    required String refreshToken,
    String? profilePicture,
  }) async {
    _userName = userName;
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _profilePicture = profilePicture;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString("access", accessToken);
    await sharedPreferences.setString("refresh", refreshToken);
    if (profilePicture != null) {
      await sharedPreferences.setString("profilePicture", profilePicture);
    }
    notifyListeners();
  }

  // Set user's name
  void setName(String name) {
    _userName = name;
    notifyListeners();
  }

  // Set profile picture URL
  void setProfilePicture(String imageUrl) async {
    _profilePicture = imageUrl;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString("profilePicture", imageUrl);
    notifyListeners();
  }

  // Upload the profile picture to the backend
  Future<void> uploadProfilePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);

      // Prepare multipart request to send the image
      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('https://localhost:8000.com/users/update_profile/'),
      );
      request.headers['Authorization'] =
          'Bearer $_accessToken'; // Pass the token
      request.files.add(
          await http.MultipartFile.fromPath('profile_picture', imageFile.path));

      // Send request
      var response = await request.send();

      if (response.statusCode == 200) {
        // If successful, parse the response and get the image URL
        var responseData = await http.Response.fromStream(response);
        var data = responseData.body; // Handle response to get the image URL
        // Assuming the URL is in the response body, update it
        setProfilePicture(data);
      } else {
        throw Exception('Failed to upload profile picture');
      }
    }
  }
}
