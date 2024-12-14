import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:planma_app/goals/widget/widget.dart';

class AddGoalScreen extends StatefulWidget {
  const AddGoalScreen({super.key});

  @override
  _AddGoalScreenState createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends State<AddGoalScreen> {
  // Controllers for input fields
  final _goalCodeController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Dropdown selections
  String? _selectedGoalType;
  String? _selectedSemester;
  String? _selectedTimeframe;
  // Duration variables
  Duration _targetDuration = const Duration(hours: 0, minutes: 30);

  // Dropdown options
  final List<String> _goalTypes = ['Academic', 'Personal'];
  final List<String> _semesters = ['First Semester', 'Second Semester'];
  final List<String> _timeframe = ['Daily', 'Weekly', 'Monthly'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Goal',
          style: GoogleFonts.openSans(
            color: const Color(0xFF173F70),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  CustomWidgets.buildTitle('Goal Name'),
                  const SizedBox(height: 12),
                  CustomWidgets.buildTextField(
                      _goalCodeController, 'Enter Goal Name'),
                  const SizedBox(height: 12),
                  CustomWidgets.buildTitle('Description'),
                  const SizedBox(height: 12),
                  CustomWidgets.buildTextField(
                      _descriptionController, 'Enter Description'),
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
                  CustomWidgets.buildTitle('Target Hours'),
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
                  CustomWidgets.buildTitle('Goal Type'),
                  const SizedBox(height: 12),
                  CustomWidgets.buildDropdownField(
                    label: 'Goal Type',
                    value: _selectedGoalType,
                    items: _goalTypes,
                    onChanged: (value) =>
                        setState(() => _selectedGoalType = value),
                  ),
                  const SizedBox(height: 12),
                  if (_selectedGoalType == 'Academic') ...[
                    CustomWidgets.buildTitle('Select Semester'),
                    const SizedBox(height: 12),
                    CustomWidgets.buildDropdownField(
                      label: 'Semester',
                      value: _selectedSemester,
                      items: _semesters,
                      onChanged: (value) =>
                          setState(() => _selectedSemester = value),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.all(16),
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
              child: Text('Add Goal',
                  style: GoogleFonts.openSans(
                    fontSize: 16,
                    color: Colors.white,
                  )),
            ),
          ),
        ],
      ),
      resizeToAvoidBottomInset: false,
    );
  }

  @override
  void dispose() {
    _goalCodeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
