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

  /// Shows a custom duration picker dialog
  Future<void> showDurationPicker(BuildContext context) async {
    // Initial selected hours and minutes from the target duration
    int selectedHours = _targetDuration.inHours;
    int selectedMinutes = _targetDuration.inMinutes % 60;

    // Show duration picker dialog
    final newDuration = await showDialog<Duration>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              title: Text(
                'Set Target Duration',
                style: GoogleFonts.openSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF173F70),
                ),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              content: SizedBox(
                width: 200,
                height: 200,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Hours Picker
                        buildPicker(
                          max: 99, // Maximum hours limit
                          selectedValue: selectedHours,
                          onSelectedItemChanged: (value) {
                            setModalState(() {
                              selectedHours = value;
                            });
                          },
                        ),
                        const Text(':',
                            style:
                                TextStyle(fontSize: 18, color: Colors.black)),
                        // Minutes Picker (0 or 30)
                        buildPicker(
                          max: 1, // Restrict to two values: 0 or 30
                          selectedValue:
                              selectedMinutes ~/ 30, // Map 0 -> 0, 30 -> 1
                          onSelectedItemChanged: (value) {
                            setModalState(() {
                              selectedMinutes =
                                  value * 30; // Map back to 0 or 30
                            });
                          },
                          // List of minutes options (00 or 30)
                          children: List<Widget>.generate(2, (index) {
                            return Center(
                              child: Text(index == 0 ? '00' : '30'),
                            );
                          }),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              actions: [
                SizedBox(height: 30),
                // Cancel button
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style:
                        GoogleFonts.openSans(fontSize: 16, color: Colors.black),
                  ),
                ),
                // Set Duration button
                ElevatedButton(
                  onPressed: (selectedHours == 0 && selectedMinutes == 0)
                      ? null
                      : () {
                          Navigator.pop(
                            context,
                            Duration(
                                hours: selectedHours, minutes: selectedMinutes),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 12.0),
                    backgroundColor: Color(0xFF173F70),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Set Duration',
                    style: GoogleFonts.openSans(
                        fontSize: 16, color: Color(0xFFFFFFFF)),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    // Update the target duration if a new value is selected
    if (newDuration != null) {
      setState(() {
        _targetDuration = newDuration;
      });
    }
  }

  /// Builds a Cupertino picker for the time fields
  Widget buildPicker({
    required int max,
    required int selectedValue,
    required Function(int) onSelectedItemChanged,
    List<Widget>? children, // Optional children parameter
  }) {
    return SizedBox(
      height: 200,
      width: 70,
      child: CupertinoPicker(
        scrollController:
            FixedExtentScrollController(initialItem: selectedValue),
        itemExtent: 50,
        onSelectedItemChanged: onSelectedItemChanged,
        children: children ??
            List<Widget>.generate(max + 1, (int index) {
              // This will hide numbers outside the desired range for hours
              if (index > max) return SizedBox.shrink(); // Hide numbers
              return Center(
                child: Text(index.toString().padLeft(2, '0'),
                    style: const TextStyle(fontSize: 16)),
              );
            }),
      ),
    );
  }

  /// Builds a title widget for each input section
  Widget buildTitle(String title) {
    return Container(
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.only(left: 16.0, top: 8.0, right: 16.0),
      child: Text(
        title,
        style: GoogleFonts.openSans(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF173F70),
        ),
      ),
    );
  }

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
                    displayText:
                        '${_targetDuration.inHours.toString().padLeft(2, '0')}:'
                        '${(_targetDuration.inMinutes % 60).toString().padLeft(2, '0')}:'
                        '${(_targetDuration.inSeconds % 60).toString().padLeft(2, '0')}',
                    onPickerTap: () async {
                      await showDurationPicker(context);
                      setState(() {}); // Update the UI after duration changes
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
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: ElevatedButton(
              onPressed: () {
                // Placeholder for goal submission logic
                print("Goal created with target duration: $_targetDuration");
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF173F70),
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 120),
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
