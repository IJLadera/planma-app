import 'package:flutter/material.dart';
import 'package:planma_app/Providers/userprof_provider.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EditProfileScreen extends StatefulWidget {
  final String username;
  final String firstName;
  final String lastName;

  EditProfileScreen({
    super.key,
    required this.username,
    required this.firstName,
    required this.lastName,
  });

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _chooseImage(BuildContext context, ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
    Navigator.pop(context); // Close the bottom sheet after selection
  }

  void _showImagePickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text(
                  'Take Photo',
                  style: GoogleFonts.openSans(fontSize: 14),
                ),
                onTap: () => _chooseImage(context, ImageSource.camera),
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text(
                  'Choose from Gallery',
                  style: GoogleFonts.openSans(fontSize: 14),
                ),
                onTap: () => _chooseImage(context, ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _uploadProfile(File? imageFile, String firstName,
      String lastName, String username) async {
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

      final uri = Uri.parse("http://127.0.0.1:8000/api/users/update_profile/");
      var request = http.MultipartRequest('PUT', uri)
        ..headers['Authorization'] = 'Bearer $accessToken'
        ..fields['firstname'] = firstName
        ..fields['lastname'] = lastName
        ..fields['username'] = username;

      if (imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath(
            'profile_picture', imageFile.path));
      }

      var response = await request.send();

      if (response.statusCode == 200) {
        _showMessage('Profile updated successfully!');
        Navigator.pop(context, {
          'username': username,
          'firstName': firstName,
          'lastName': lastName,
        });
      } else {
        _showMessage(
            'Failed to update profile. Status code: ${response.statusCode}');
      }
    } catch (e) {
      _showMessage('Error during upload: $e');
    } finally {
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
    final usernameController = TextEditingController(text: widget.username);
    final firstNameController = TextEditingController(text: widget.firstName);
    final lastNameController = TextEditingController(text: widget.lastName);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Edit Profile',
          style: GoogleFonts.openSans(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF173F70),
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.yellow,
                    backgroundImage: _image != null ? FileImage(_image!) : null,
                    child: _image == null
                        ? Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.black,
                          )
                        : null,
                  ),
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Color(0xFF173F70),
                    child: IconButton(
                      icon: Icon(Icons.edit, size: 16, color: Colors.white),
                      onPressed: () => _showImagePickerOptions(context),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              // Username Field
              TextFormField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: 20),
              // First Name Field
              TextFormField(
                controller: firstNameController,
                decoration: InputDecoration(
                  labelText: 'First Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Last Name Field
              TextFormField(
                controller: lastNameController,
                decoration: InputDecoration(
                  labelText: 'Last Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: 30),
              // Save Changes Button
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _uploadProfile(
                      _image,
                      firstNameController.text,
                      lastNameController.text,
                      usernameController.text,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF173F70),
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 100),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : Text(
                        'Save Changes',
                        style: GoogleFonts.openSans(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
