import 'package:flutter/material.dart';
import 'package:planma_app/Providers/class_schedule_provider.dart';
import 'package:planma_app/Providers/semester_provider.dart';
import 'package:planma_app/subject/widget/add_semester.dart';
import 'package:planma_app/subject/widget/widget.dart';
import 'package:provider/provider.dart';

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

  String? selectedSemester;
  int? selectedSemesterId;
  String? selectedSemId;
  String? _selectedDay;

  final Map<String, String> dayAbbreviationToFull = {
  'S': 'Sunday',
  'M': 'Monday',
  'T': 'Tuesday',
  'W': 'Wednesday',
  'Th': 'Thursday',
  'F': 'Friday',
  'Sa': 'Saturday',
  };

  Future<void> _selectTime(
      BuildContext context, TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 12, minute: 0),
    );
    if (picked != null) {
      setState(() {
        controller.text = picked.format(context);
      });
    }
  }

  TimeOfDay? _stringToTimeOfDay(String timeString) {
    try {
      final timeParts = timeString.split(':');
      final hour = int.parse(timeParts[0].trim());
      final minuteParts = timeParts[1].split(' ');
      final minute = int.parse(minuteParts[0].trim());
      final period = minuteParts[1].toLowerCase();

      // Adjust for AM/PM
      final isPM = period == 'pm';
      final adjustedHour = (isPM && hour != 12) ? hour + 12 : (hour == 12 && !isPM ? 0 : hour);

      return TimeOfDay(hour: adjustedHour, minute: minute);
    } catch (e) {
      return null; // Return null if parsing fails
    }
  }

  void _submitClassSchedule(BuildContext context) async {
    final provider = Provider.of<ClassScheduleProvider>(context, listen: false);

    String subjectCode = _subjectCodeController.text.trim();
    String subjectTitle = _subjectTitleController.text.trim();
    String startTimeString = _startTimeController.text.trim();
    String endTimeString = _endTimeController.text.trim();
    String room = _roomController.text.trim();

    // Convert String to TimeOfDay
    final startTime = _stringToTimeOfDay(startTimeString);
    final endTime = _stringToTimeOfDay(endTimeString);

    if (subjectCode.isEmpty ||
        subjectTitle.isEmpty ||
        room.isEmpty ||
        startTimeString.isEmpty ||
        endTimeString.isEmpty ||
        _selectedDay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields!')),
      );
      return;
    }

    if (!_isValidTimeRange(startTime!, endTime!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Start Time must be before End Time.')),
      );
      return;
    }

    // Log for now (you can replace with API/database calls)
    print("Subject Code: $subjectCode");
    print("Subject Title: $subjectTitle");
    print("Semester: $selectedSemesterId");
    print("Days: $_selectedDay");
    print("Start Time: $startTime");
    print("End Time: $endTime");
    print("Room: $room");

    try {
      await provider.addClassScheduleWithSubject(
        subjectCode: subjectCode,
        subjectTitle: subjectTitle,
        semesterId: selectedSemesterId!,
        dayOfWeek: _selectedDay!,
        startTime: startTime,
        endTime: endTime,
        room: room
      );

      

      // After validation and adding logic
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Class Schedule added successfully!')),
      );

      Navigator.pop(context);
      // Clear fields after adding
      _clearFields();

    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add class schedule 1: $error')),
      );
    }
  }

  // Valid Time Range Check
  bool _isValidTimeRange(TimeOfDay startTime, TimeOfDay endTime) {
  return startTime.hour < endTime.hour ||
      (startTime.hour == endTime.hour && startTime.minute < endTime.minute);
  }

  // Clear fields after submit
  void _clearFields() {
    _subjectCodeController.clear();
    _subjectTitleController.clear();
    _startTimeController.clear();
    _endTimeController.clear();
    _roomController.clear();
    _selectedDay = null;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    // Fetch semesters when the screen loads
    final semesterProvider = Provider.of<SemesterProvider>(context, listen: false);
    semesterProvider.fetchSemesters().then((_) {
      setState(() {
        // Set default value if there are semesters available
        if (semesterProvider.semesters.isNotEmpty) {
          // Select the first semester
          selectedSemester = "${semesterProvider.semesters[0]['acad_year_start']} - ${semesterProvider.semesters[0]['acad_year_end']} ${semesterProvider.semesters[0]['semester']}";
        
          final defaultSemester = semesterProvider.semesters.first;
          selectedSemesterId = defaultSemester['semester_id'];

          // Log the selected semester
          print("Default selected semester: $selectedSemester");
          print("Default selected semester ID: $selectedSemesterId");
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Class Schedule'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer<SemesterProvider>(
        builder: (context, semesterProvider, child) {
          // Prepare the dropdown list of semesters
          List<Map<String, dynamic>> semesters = semesterProvider.semesters;
          List<String> semesterItems = semesters
              .map((semester) =>
                  "${semester['acad_year_start']} - ${semester['acad_year_end']} ${semester['semester']}")
              .toList();
          semesterItems.add('- Add Semester -'); // Add option for new semester
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomWidgets.buildTextField(
                          _subjectCodeController, 'Subject Code'),
                      const SizedBox(height: 16),
                      CustomWidgets.buildTextField(
                          _subjectTitleController, 'Subject Title'),
                      const SizedBox(height: 16),
                      // Dropdown for Semester
                      CustomWidgets.buildDropdownField(
                        label: 'Select Semester',
                        value: selectedSemester,
                        items: semesterItems,
                        onChanged: (value) {
                          setState(() {
                            if (value == '- Add Semester -') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => AddSemesterScreen()),
                              ).then((_) => semesterProvider.fetchSemesters());
                            } else {
                              selectedSemester = value;

                              // Split data from value for firstWhere comparison
                              List<String> semesterParts = selectedSemester!.split(' ');
                              int acadYearStart = int.parse(semesterParts[0]);
                              int acadYearEnd = int.parse(semesterParts[2]);
                              String semesterType = "${semesterParts[3]} ${semesterParts[4]}";
                              
                              final selectedSemesterMap = semesterProvider.semesters.firstWhere(
                                (semester) {
                                  return semester['acad_year_start'] == acadYearStart &&
                                  semester['acad_year_end'] == acadYearEnd &&
                                  semester['semester'] == semesterType;
                                }, orElse: () => {},  // Return null if no match is found
                              );
                              selectedSemesterId = selectedSemesterMap['semester_id'];
                              print("Found semester ID: ${selectedSemesterMap['semester_id']}");
                            }
                          });
                        },
                        backgroundColor: const Color(0xFFF5F5F5),
                        labelColor: Colors.black,
                        textColor: Colors.black,
                        borderRadius: 30.0,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        fontSize: 14.0,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Day of the Week',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          for (var day in ['S', 'M', 'T', 'W', 'Th', 'F', 'Sa'])
                            DayButton(
                              day: day,
                              isSelected: _selectedDay == dayAbbreviationToFull[day], // Match full day name
                              onTap: () {
                                setState(() {
                                  if (_selectedDay == dayAbbreviationToFull[day]) {
                                    _selectedDay = null;
                                  } else {
                                    _selectedDay = dayAbbreviationToFull[day];
                                  }
                                });
                              },
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  _selectTime(context, _startTimeController),
                              child: AbsorbPointer(
                                child: CustomWidgets.buildTextField(
                                    _startTimeController, 'Start Time'),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  _selectTime(context, _endTimeController),
                              child: AbsorbPointer(
                                child: CustomWidgets.buildTextField(
                                    _endTimeController, 'End Time'),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      CustomWidgets.buildTextField(_roomController, 'Room'),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 20.0),
                child: ElevatedButton(
                  onPressed: () => _submitClassSchedule(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF173F70),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 120),
                  ),
                  child: const Text(
                    'Add Schedule',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
