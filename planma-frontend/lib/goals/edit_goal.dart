import 'package:flutter/material.dart';
import 'package:planma_app/goals/widget/widget.dart'; // Ensure this file contains the CustomWidgets class

class EditGoal extends StatefulWidget {
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
        title: const Text('Edit Goal Sessions'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Target Duration:',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      TextButton(
                        onPressed: () => _pickTargetDuration(context),
                        child: Text(
                          '${_targetDuration.inHours} hrs ${_targetDuration.inMinutes % 60} mins',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(thickness: 1, height: 16),
                  const SizedBox(height: 16),
                  CustomWidgets.buildDropdownField(
                      'Goal Type', _selectedGoalType, _goalType, (value) {
                    setState(() {
                      _selectedGoalType = value;
                    });
                  }),
                  const SizedBox(height: 16),
                  CustomWidgets.buildDropdownField(
                      'Semester', _selectedSemester, _semesters, (value) {
                    setState(() {
                      _selectedSemester = value;
                    });
                  }),
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
              child: const Text(
                'Edit Goal Session',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
