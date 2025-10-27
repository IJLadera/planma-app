import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:planma_app/Providers/userprof_provider.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EditProfileScreen extends StatefulWidget {
  final String username;
  final String firstName;
  final String lastName;
  final String? profilePictureUrl;

  EditProfileScreen({
    super.key,
    required this.username,
    required this.firstName,
    required this.lastName,
    this.profilePictureUrl,
  });

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  File? _image;
  Uint8List? _webImage; // Store image in memory for Web
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  late String? _initialProfilePicture;
  String? initProfilePictureFullUrl;

  // Base API URL - adjust this to match your backend URL
  late final String _baseApiUrl;

  @override
  void initState() {
    super.initState();
    _initialProfilePicture = widget.profilePictureUrl;

    // Use dotenv to get API_URL and remove trailing slash if present
    String baseUrl =
        dotenv.env['API_URL'] ?? 'https://planma-app-production.up.railway.app';
    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }
    _baseApiUrl = baseUrl;

    // Ensure the URL is absolute
    String getFullImageUrl(String? url) {
      if (url == null || url.isEmpty) {
        return ''; // Return empty string if there's no URL
      }

      // If the URL from the backend is already a full valid URL, use it directly.
      if (url.startsWith('http')) {
        return url;
      }

      // Otherwise, construct the full URL.
      // This correctly adds the '/media/' part and the slash.
      return '$_baseApiUrl/media/$url';
    }

    initProfilePictureFullUrl = getFullImageUrl(_initialProfilePicture);
  }

  ImageProvider<Object>? getImageProvider() {
    if (_webImage != null) {
      return MemoryImage(_webImage!);
    } else if (_image != null) {
      return FileImage(_image!);
    } else if (initProfilePictureFullUrl != null) {
      return NetworkImage(initProfilePictureFullUrl!);
    }
    return null;
  }

  Future<void> _chooseImage(BuildContext context, ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _webImage = bytes; // Store for web use
          _initialProfilePicture = null; // Override existing profile picture
        });
      } else {
        setState(() {
          _image = File(pickedFile.path);
          _initialProfilePicture = null; // Override existing profile picture
        });
      }
    }
    Navigator.pop(context);
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
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
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
                      backgroundImage: getImageProvider(),
                      child: (getImageProvider() == null)
                          ? Icon(Icons.person, size: 50, color: Colors.black)
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
                      XFile? imageFile;

                      if (kIsWeb && _webImage != null) {
                        imageFile = XFile.fromData(_webImage!);
                      } else if (_image != null) {
                        imageFile = XFile(_image!.path);
                      }

                      context.read<UserProfileProvider>().updateUserProfile(
                          firstNameController.text,
                          lastNameController.text,
                          usernameController.text,
                          imageFile: imageFile);
                      Navigator.pop(context, {
                        'username': usernameController.text,
                        'firstName': firstNameController.text,
                        'lastName': lastNameController.text,
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF173F70),
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 100),
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
      ),
      resizeToAvoidBottomInset: false,
    );
  }
}
