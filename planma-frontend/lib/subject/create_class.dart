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

  String? _selectedSemester;
  final List<String> _semesters = ['1', '2', 'Summer'];
  final Set<String> _selectedDays = {};
  TimeOfDay _startTime = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 8, minute: 0);

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
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
                  CustomWidgets.buildTextField(
                      _subjectCodeController, 'Subject Code'),
                  const SizedBox(height: 16), // Increased space
                  CustomWidgets.buildTextField(
                      _subjectTitleController, 'Subject Title'),
                  const SizedBox(height: 16), // Increased space
                  CustomWidgets.buildDropdownField(
                      'Semester', _selectedSemester, _semesters, (value) {
                    setState(() {
                      _selectedSemester = value;
                    });
                  }),
                  const SizedBox(height: 16), // Space above the days row
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
                        const SizedBox(width: 10), // Space between each DayButton
                      ],
                    ],
                  ),
                  const SizedBox(
                      height: 16), // Space between the days and time fields
                  Row(
                    children: [
                      Expanded(
                          child: CustomWidgets.buildTimeField('Start Time',
                              _startTime, context, true, _selectTime)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: CustomWidgets.buildTimeField('End Time',
                              _endTime, context, false, _selectTime)),
                    ],
                  ),
                  const SizedBox(
                      height: 16), // Space between time fields and room field
                  CustomWidgets.buildTextField(_roomController, 'Room'),
                  const SizedBox(height: 20), // Added more gap below the last field
                ],
              ),
            )),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              child: ElevatedButton(
                onPressed: () {
                  // Create task action
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 120),
                ),
                child: const Text(
                  'Create Subject',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ));
  }
}
