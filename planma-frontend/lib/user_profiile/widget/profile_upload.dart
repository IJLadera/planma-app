import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class ImageUpload extends StatefulWidget {
  @override
  _ImageUploadState createState() => _ImageUploadState();
}

class _ImageUploadState extends State<ImageUpload> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;

  Future<void> _chooseImageFromCamera() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        setState(() {
          _image = pickedFile;
        });
        _uploadImage(File(_image!.path));
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
        _uploadImage(File(_image!.path));
      }
    } catch (e) {
      _showMessage('Failed to pick image: $e');
    }
  }

  Future<void> _uploadImage(File imageFile) async {
    try {
      var uri = Uri.parse(
          'https://example.com/upload'); // Replace with your API endpoint
      var request = http.MultipartRequest('POST', uri);
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );

      var response = await request.send();
      if (response.statusCode == 200) {
        _showMessage('Image uploaded successfully');
      } else {
        _showMessage(
            'Failed to upload image. Status code: ${response.statusCode}');
      }
    } catch (e) {
      _showMessage('Error during upload: $e');
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _chooseImageFromCamera,
              child: const Text("Take Photo"),
            ),
            ElevatedButton(
              onPressed: _chooseImageFromGallery,
              child: const Text("Choose from Gallery"),
            ),
            if (_image != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Image.file(
                  File(_image!.path),
                  height: 200,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
