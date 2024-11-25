import 'package:flutter/material.dart';
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

  void _addClassSchedule() {
    String subjectCode = _subjectCodeController.text.trim();
    String subjectTitle = _subjectTitleController.text.trim();
    String startTime = _startTimeController.text.trim();
    String endTime = _endTimeController.text.trim();
    String room = _roomController.text.trim();

    if (subjectCode.isEmpty ||
        subjectTitle.isEmpty ||
        room.isEmpty ||
        startTime.isEmpty ||
        endTime.isEmpty ||
        _selectedDays.isEmpty) {
      _showErrorDialog("All fields are required!");
      return;
    }

    if (!_isValidTimeRange(startTime, endTime)) {
      _showErrorDialog("Start Time must be before End Time.");
      return;
    }

    // Log for now (you can replace with API/database calls)
    print("Subject Code: $subjectCode");
    print("Subject Title: $subjectTitle");
    print("Semester: $selectedSemesterId");
    print("Days: $_selectedDays");
    print("Start Time: $startTime");
    print("End Time: $endTime");
    print("Room: $room");

    // After validation and adding logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Class Schedule Added Successfully!')),
    );

    // Clear fields after adding
    _clearFields();
  }

  bool _isValidTimeRange(String startTime, String endTime) {
    try {
      final start = TimeOfDay(
          hour: int.parse(startTime.split(":")[0]),
          minute: int.parse(startTime.split(":")[1].split(" ")[0]));
      final end = TimeOfDay(
          hour: int.parse(endTime.split(":")[0]),
          minute: int.parse(endTime.split(":")[1].split(" ")[0]));
      return start.hour < end.hour ||
          (start.hour == end.hour && start.minute < end.minute);
    } catch (e) {
      return false; // Invalid time format
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  void _clearFields() {
    _subjectCodeController.clear();
    _subjectTitleController.clear();
    _startTimeController.clear();
    _endTimeController.clear();
    _roomController.clear();
    _selectedDays.clear();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    // Fetch semesters when the screen loads
    final semesterProvider =
        Provider.of<SemesterProvider>(context, listen: false);
    semesterProvider.fetchSemesters().then((_) {
      setState(() {
        // Set default value if there are semesters available
        if (semesterProvider.semesters.isNotEmpty) {
          selectedSemester =
              "${semesterProvider.semesters[0]['acad_year_start']} - ${semesterProvider.semesters[0]['acad_year_end']} ${semesterProvider.semesters[0]['semester']}";
          selectedSemesterId =
              semesterProvider.semesters[0]['id']; // Capture the semester ID
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
                              if (selectedSemesterMap != null) {
                                selectedSemesterId = selectedSemesterMap['semester_id'];
                                print("Found semester ID: ${selectedSemesterMap['semester_id']}");
                              } else {
                                print("No matching semester found for acad_year_start: $acadYearStart.");
                              }  
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
                        'Days',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          for (var day in ['S', 'M', 'T', 'W', 'TH', 'F', 'Sa'])
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
                  onPressed: _addClassSchedule,
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
