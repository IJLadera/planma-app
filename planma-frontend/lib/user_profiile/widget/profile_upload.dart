import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ImageUpload extends StatefulWidget {
  @override
  _ImageUploadState createState() => _ImageUploadState();
}

class _ImageUploadState extends State<ImageUpload> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;

  Future<void> _chooseImageFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    setState(() {
      _image = pickedFile;
    });

    if (_image != null) {
      _uploadImage(File(_image!.path));
    }
  }

  Future<void> _chooseImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = pickedFile;
    });

    if (_image != null) {
      _uploadImage(File(_image!.path));
    }
  }

  Future<void> _uploadImage(File imageFile) async {
    var uri = Uri.parse('https://example.com/upload');
    var request = http.MultipartRequest('POST', uri);
    request.files.add(
      await http.MultipartFile.fromPath('image', imageFile.path),
    );

    var response = await request.send();
    if (response.statusCode == 200) {
      print('Image uploaded successfully');
    } else {
      print('Failed to upload image');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Image Upload Example')),
      body: Column(
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
              padding: const EdgeInsets.all(16.0),
              child: Image.file(File(_image!.path), height: 200),
            ),
        ],
      ),
    );
  }
}
