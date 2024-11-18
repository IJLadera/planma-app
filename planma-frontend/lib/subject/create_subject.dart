import 'package:flutter/material.dart';
import 'package:planma_app/subject/widget/widget.dart';

class AddClassScreen extends StatefulWidget {
  const AddClassScreen({super.key});

  @override
  _AddClassScreenState createState() => _AddClassScreenState();
}

class _AddClassScreenState extends State<AddClassScreen> {
  final _subjectCodeController = TextEditingController();
  final _subjectTitleController = TextEditingController();
  final _roomController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();

  String? _selectedSemester;
  final List<String> _semesters = ['1', '2', 'Summer'];
  final Set<String> _selectedDays = {};

  Future<void> _selectTime(
      BuildContext context, TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        controller.text = picked.format(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Class'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  CustomWidgets.buildTextField(
                      _subjectCodeController, 'Subject Code'),
                  const SizedBox(height: 16),
                  CustomWidgets.buildTextField(
                      _subjectTitleController, 'Subject Title'),
                  const SizedBox(height: 16),
                  CustomWidgets.buildDropdownField(
                    'Semester',
                    _selectedSemester,
                    _semesters,
                    (value) => setState(() {
                      _selectedSemester = value;
                    }),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      for (var day in [
                        'S',
                        'M',
                        'T',
                        'W',
                        'TH',
                        'F',
                        'Sa'
                      ]) ...[
                        DayButton(
                          day: day,
                          isSelected: _selectedDays.contains(day),
                          onTap: () {
                            setState(() {
                              if (_selectedDays.contains(day)) {
                                _selectedDays.remove(day);
                              } else {
                                _selectedDays.add(day);
                              }
                            });
                          },
                        ),
                        const SizedBox(width: 10),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: CustomWidgets.buildTimeField(
                          'Start Time',
                          _startTimeController,
                          context,
                          (context) =>
                              _selectTime(context, _startTimeController),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomWidgets.buildTimeField(
                          'End Time',
                          _endTimeController,
                          context,
                          (context) => _selectTime(context, _endTimeController),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CustomWidgets.buildTextField(_roomController, 'Room'),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: ElevatedButton(
              onPressed: () {
                // Collect all the data here
                String subjectCode = _subjectCodeController.text;
                String subjectTitle = _subjectTitleController.text;
                String room = _roomController.text;
                print("Subject Code: $subjectCode");
                print("Subject Title: $subjectTitle");
                print("Start Time: ${_startTimeController.text}");
                print("End Time: ${_endTimeController.text}");
                print("Room: $room");
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF173F70),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 120),
              ),
              child: const Text(
                'Create Subject',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
