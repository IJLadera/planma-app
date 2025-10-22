import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class ImageUpload extends StatefulWidget {
  @override
  _ImageUploadState createState() => _ImageUploadState();
}

class _ImageUploadState extends State<ImageUpload> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  bool _isLoading = false;

  // Base API URL
  late final String _baseApiUrl;
  @override
  void initState() {
    super.initState();
    // Remove trailing slash if present in API_URL
    String baseUrl =
        dotenv.env['API_URL'] ?? 'http://planma-app-production.up.railway.app';
    if (baseUrl.endsWith('/'))
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    _baseApiUrl = baseUrl;
  }

  Future<void> _chooseImageFromCamera() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        setState(() {
          _image = pickedFile;
        });
        await _uploadImage(File(_image!.path));
      }
    } catch (e) {
      _showMessage('Failed to capture image: $e');
    }
  }

  Future<void> _chooseImageFromGallery() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _image = pickedFile;
        });
        await _uploadImage(File(_image!.path));
      }
    } catch (e) {
      _showMessage('Failed to pick image: $e');
    }
  }

  Future<void> _uploadImage(File imageFile) async {
    setState(() {
      _isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('access');

      if (accessToken == null) {
        _showMessage('Access token is missing!');
        return;
      }

      var uri = Uri.parse('$_baseApiUrl/users/update_profile/');
      var request = http.MultipartRequest('PUT', uri)
        ..headers['Authorization'] = 'Bearer $accessToken'; // Pass the token
      request.files.add(
          await http.MultipartFile.fromPath('profile_picture', imageFile.path));

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await http.Response.fromStream(response);
        // Assuming the response contains the image URL or success data
        String imageUrl =
            responseData.body; // Update based on your API response format

        // Save the image URL in SharedPreferences
        prefs.setString('profilePicture', imageUrl);

        _showMessage('Image uploaded successfully');
        setState(() {
          _isLoading = false;
        });
      } else {
        _showMessage(
            'Failed to upload image. Status code: ${response.statusCode}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      _showMessage('Error during upload: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Image Upload Example')),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _chooseImageFromCamera,
                child: Text(
                  "Take Photo",
                  style: GoogleFonts.openSans(fontSize: 16),
                ),
              ),
              ElevatedButton(
                onPressed: _chooseImageFromGallery,
                child: Text(
                  "Choose from Gallery",
                  style: GoogleFonts.openSans(fontSize: 16),
                ),
              ),
              if (_image != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Image.file(
                    File(_image!.path),
                    height: 200,
                  ),
                ),
              if (_isLoading)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        ),
      ),
      resizeToAvoidBottomInset: false,
    );
  }
}
