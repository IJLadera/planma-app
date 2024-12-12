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

  /// Shows a custom duration picker dialog
  Future<void> showDurationPicker(BuildContext context) async {
    int selectedHours = _targetDuration.inHours;
    int selectedMinutes = _targetDuration.inMinutes % 60;
    int selectedSeconds = _targetDuration.inSeconds % 60;

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
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20.0, vertical: 20.0), // Add padding to content
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
                          max: 999,
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
                        // Minutes Picker
                        buildPicker(
                          max: 59,
                          selectedValue: selectedMinutes,
                          onSelectedItemChanged: (value) {
                            setModalState(() {
                              selectedMinutes = value;
                            });
                          },
                        ),
                        const Text(':',
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.black)), // Seconds Picker
                        buildPicker(
                          max: 59,
                          selectedValue: selectedSeconds,
                          onSelectedItemChanged: (value) {
                            setModalState(() {
                              selectedSeconds = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style:
                        GoogleFonts.openSans(fontSize: 16, color: Colors.black),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      Duration(
                        hours: selectedHours,
                        minutes: selectedMinutes,
                        seconds: selectedSeconds,
                      ),
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
  }) {
    return SizedBox(
      height: 200,
      width: 70,
      child: CupertinoPicker(
        scrollController:
            FixedExtentScrollController(initialItem: selectedValue),
        itemExtent: 50,
        onSelectedItemChanged: onSelectedItemChanged,
        children: List<Widget>.generate(max + 1, (int index) {
          return Center(
            child: Text(index.toString().padLeft(2, '0'),
                style: const TextStyle(fontSize: 16)),
          );
        }),
      ),
    );
  }

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

  /// Builds an input field widget
  Widget buildTextField(
    TextEditingController controller,
    String hintText,
  ) {
    return CustomWidgets.buildTextField(controller, hintText);
  }

  /// Builds a dropdown field
  Widget buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return CustomWidgets.buildDropdownField(
      label: label,
      value: value,
      items: items,
      onChanged: onChanged,
    );
  }

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
                  buildTitle(
                    'Goal Name',
                  ),
                  const SizedBox(height: 12),
                  CustomWidgets.buildTextField(
                    _goalCodeController,
                    'Goal Name',
                  ),
                  const SizedBox(height: 12),
                  buildTitle(
                    'Description',
                  ),
                  const SizedBox(height: 12),
                  CustomWidgets.buildTextField(
                    _descriptionController,
                    'Description',
                  ),
                  const SizedBox(height: 12),
                  buildTitle('Timeframe'),
                  const SizedBox(height: 12),
                  buildDropdownField(
                    label: 'Timeframe',
                    value: _selectedTimeframe,
                    items: _timeframe,
                    onChanged: (value) =>
                        setState(() => _selectedTimeframe = value),
                  ),
                  const SizedBox(height: 12),
                  buildTitle('Target Duration'),
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
                  buildTitle(
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
                  buildTitle(
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
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 120),
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
