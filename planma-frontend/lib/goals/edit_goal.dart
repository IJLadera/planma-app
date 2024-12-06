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
  Duration _targetDuration = const Duration(hours: 0, minutes: 30);

  final List<String> _goalType = ['Academic', 'Personal'];
  final List<String> _semesters = ['First Semester', 'Second Semester'];

  Future<void> _pickTargetDuration(BuildContext context) async {
    final Duration? pickedDuration = await showModalBottomSheet<Duration>(
      context: context,
      builder: (BuildContext context) {
        int selectedHours = _targetDuration.inHours;
        int selectedMinutes = _targetDuration.inMinutes % 60;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Select Target Duration',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Hours Picker
                      Column(
                        children: [
                          const Text('Hours', style: TextStyle(fontSize: 16)),
                          SizedBox(
                            height: 150,
                            width: 70,
                            child: ListWheelScrollView.useDelegate(
                              itemExtent: 40,
                              onSelectedItemChanged: (value) {
                                setModalState(() {
                                  selectedHours = value;
                                });
                              },
                              childDelegate: ListWheelChildBuilderDelegate(
                                builder: (context, index) => Text('$index',
                                    style: const TextStyle(fontSize: 18)),
                                childCount: 24, // Maximum hours
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 20),
                      // Minutes Picker
                      Column(
                        children: [
                          const Text('Minutes', style: TextStyle(fontSize: 16)),
                          SizedBox(
                            height: 150,
                            width: 70,
                            child: ListWheelScrollView.useDelegate(
                              itemExtent: 40,
                              onSelectedItemChanged: (value) {
                                setModalState(() {
                                  selectedMinutes = value;
                                });
                              },
                              childDelegate: ListWheelChildBuilderDelegate(
                                builder: (context, index) => Text('$index',
                                    style: const TextStyle(fontSize: 18)),
                                childCount: 60, // Maximum minutes
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(
                          context,
                          Duration(
                              hours: selectedHours, minutes: selectedMinutes));
                    },
                    child: const Text('Set Duration'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (pickedDuration != null) {
      setState(() {
        _targetDuration = pickedDuration;
      });
    }
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
                  const SizedBox(height: 16),
                  CustomWidgets.buildTextField(
                    _goalCodeController,
                    'Goal Name',
                  ),
                  const SizedBox(height: 16),
                  CustomWidgets.buildTextField(
                    _descriptionController,
                    'Description',
                  ),
                  const SizedBox(height: 16),
                  // Target Duration Section
                  Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0), // Add desired margin
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Target Duration:',
                          style: GoogleFonts.openSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Row(
                          children: [
                            // Hour Picker
                            CustomWidgets.buildPicker(
                              max: 24,
                              selectedValue: _targetDuration.inHours,
                              onSelectedItemChanged: (value) {
                                setState(() {
                                  _targetDuration = Duration(
                                    hours: value,
                                    minutes: _targetDuration.inMinutes % 60,
                                  );
                                });
                              },
                            ),
                            Text(
                              ' hrs ',
                              style: GoogleFonts.openSans(
                                fontSize: 14,
                              ),
                            ),

                            // Minute Picker
                            CustomWidgets.buildPicker(
                              max: 60,
                              selectedValue: _targetDuration.inMinutes % 60,
                              onSelectedItemChanged: (value) {
                                setState(() {
                                  _targetDuration = Duration(
                                    hours: _targetDuration.inHours,
                                    minutes: value,
                                  );
                                });
                              },
                            ),
                            Text(
                              ' mins ',
                              style: GoogleFonts.openSans(
                                fontSize: 14,
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomWidgets.buildDropdownField(
                    label: 'Goal Type',
                    value: _selectedGoalType,
                    items: _goalType,
                    onChanged: (String? value) =>
                        setState(() => _selectedGoalType = value),
                  ),
                  const SizedBox(height: 16),
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
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 20.0,
            ),
            child: ElevatedButton(
              onPressed: () {
                // TODO: Add functionality to save the goal session
                print(
                    "Target Duration: ${_targetDuration.inHours} hrs ${_targetDuration.inMinutes % 60} mins");
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF173F70),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 120,
                ),
              ),
              child: Text(
                'Edit Goal',
                style: GoogleFonts.openSans(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
