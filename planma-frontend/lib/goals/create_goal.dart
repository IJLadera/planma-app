import 'package:flutter/material.dart';
import 'package:planma_app/goals/widget/widget.dart';
import 'package:google_fonts/google_fonts.dart';

class AddGoalScreen extends StatefulWidget {
  const AddGoalScreen({super.key});

  @override
  _AddGoalScreenState createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends State<AddGoalScreen> {
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
                  Text(
                    'Select Target Duration',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'OpenSans', // Use OpenSans font
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildPicker(
                        'Hours',
                        24,
                        selectedHours,
                        (value) => setModalState(() => selectedHours = value),
                      ),
                      const SizedBox(width: 20),
                      _buildPicker(
                        'Minutes',
                        60,
                        selectedMinutes,
                        (value) => setModalState(() => selectedMinutes = value),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(
                        context,
                        Duration(
                            hours: selectedHours, minutes: selectedMinutes),
                      );
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

  Widget _buildPicker(String label, int itemCount, int initialValue,
      Function(int) onSelectedItemChanged) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        SizedBox(
          height: 150,
          width: 70,
          child: ListWheelScrollView.useDelegate(
            itemExtent: 40,
            onSelectedItemChanged: onSelectedItemChanged,
            childDelegate: ListWheelChildBuilderDelegate(
              builder: (context, index) => Text(
                '$index',
                style: const TextStyle(fontSize: 18),
              ),
              childCount: itemCount,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Goal',
          style: GoogleFonts.openSans(
            color: Color(0xFF173F70),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
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
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
            child: ElevatedButton(
              onPressed: () {
                // TODO: Add functionality to save the goal session
                print(
                  "Target Duration: ${_targetDuration.inHours} hrs ${_targetDuration.inMinutes % 60} mins",
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF173F70),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 100),
              ),
              child: Text(
                'Create Goal',
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
