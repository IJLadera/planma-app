import 'package:flutter/material.dart';
import 'package:planma_app/subject/widget/widget.dart';

class EditSemesterScreen extends StatefulWidget {
  @override
  _EditSemesterScreenState createState() => _EditSemesterScreenState();
}

class _EditSemesterScreenState extends State<EditSemesterScreen> {
  final _academicCodeController = TextEditingController();
  final _yearLevelController = TextEditingController();
  final _startandendController = TextEditingController();

  String? _selectedSemester;
  final List<String> _semesterOptions = ['1st Semester', '2nd Semester'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Semester'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomWidgets.buildTextField(
              _academicCodeController,
              'Academic Year',
            ),
            const SizedBox(height: 16),
            CustomWidgets.buildTextField(
              _yearLevelController,
              'Year Level',
            ),
            const SizedBox(height: 16),
            CustomWidgets.buildDropdownField(
              label: 'Semester',
              value: _selectedSemester,
              items: _semesterOptions,
              onChanged: (String? value) {
                setState(() {
                  _selectedSemester = value;
                });
              },
            ),
            const SizedBox(height: 16),
            CustomWidgets.buildTextField(
              _startandendController,
              'Start & End Date',
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Add functionality for editing semester
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF173F70), // Button color
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                child: const Text(
                  'Edit Semester',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
