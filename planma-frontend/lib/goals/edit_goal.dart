import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:planma_app/goals/widget/widget.dart';
import 'package:google_fonts/google_fonts.dart';

class EditGoal extends StatefulWidget {
  const EditGoal({super.key});

  @override
  _EditGoal createState() => _EditGoal();
}

class _EditGoal extends State<EditGoal> {
  final _goalCodeController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedGoalType;
  String? _selectedSemester;
  String? _selectedTimeframe;

  Duration _targetDuration = const Duration(hours: 0, minutes: 30);

  final List<String> _goalType = ['Academic', 'Personal'];
  final List<String> _semesters = ['First Semester', 'Second Semester'];
  final List<String> _timeframe = ['Daily', 'Weekly', 'Monthly'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Goal',
          style: GoogleFonts.openSans(
            color: Color(0xFF173F70),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Color(0xFFFFFFFF),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  CustomWidgets.buildTitle(
                    'Goal Name',
                  ),
                  const SizedBox(height: 12),
                  CustomWidgets.buildTextField(
                    _goalCodeController,
                    'Goal Name',
                  ),
                  const SizedBox(height: 12),
                  CustomWidgets.buildTitle(
                    'Description',
                  ),
                  const SizedBox(height: 12),
                  CustomWidgets.buildTextField(
                    _descriptionController,
                    'Description',
                  ),
                  const SizedBox(height: 12),
                  CustomWidgets.buildTitle('Timeframe'),
                  const SizedBox(height: 12),
                  CustomWidgets.buildDropdownField(
                    label: 'Timeframe',
                    value: _selectedTimeframe,
                    items: _timeframe,
                    onChanged: (value) =>
                        setState(() => _selectedTimeframe = value),
                  ),
                  const SizedBox(height: 12),
                  CustomWidgets.buildTitle('Target Duration'),
                  const SizedBox(height: 12),
                  CustomWidgets.buildScheduleDatePicker(
                    context: context,
                    displayText: CustomWidgets.formatDurationText(
                        _targetDuration), // Correct call
                    onPickerTap: () async {
                      // Pass the required arguments: context, initialDuration, and the callback function
                      await CustomWidgets.showDurationPicker(
                          context, _targetDuration, (newDuration) {
                        setState(() {
                          _targetDuration =
                              newDuration; // Update target duration
                        });
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  CustomWidgets.buildTitle(
                    'Goal Type',
                  ),
                  const SizedBox(height: 12),
                  CustomWidgets.buildDropdownField(
                    label: 'Goal Type',
                    value: _selectedGoalType,
                    items: _goalType,
                    onChanged: (String? value) =>
                        setState(() => _selectedGoalType = value),
                  ),
                  const SizedBox(height: 12),
                  CustomWidgets.buildTitle(
                    'Select Semester',
                  ),
                  const SizedBox(height: 12),
                  CustomWidgets.buildDropdownField(
                    label: 'Semester',
                    value: _selectedSemester,
                    items: _semesters,
                    onChanged: (String? value) =>
                        setState(() => _selectedSemester = value),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: ElevatedButton(
              onPressed: () {
                // Placeholder for goal submission logic
                print("Goal created with target duration: $_targetDuration");
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF173F70),
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 100),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Edit Goal',
                  style: GoogleFonts.openSans(
                    fontSize: 16,
                    color: Colors.white,
                  )),
            ),
          ),
        ],
      ),
    );
  }
}
