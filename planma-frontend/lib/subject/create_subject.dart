import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:planma_app/Providers/class_schedule_provider.dart';
import 'package:planma_app/Providers/semester_provider.dart';
import 'package:planma_app/subject/semester/add_semester.dart';
import 'package:planma_app/subject/widget/widget.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts

class AddClassScreen extends StatefulWidget {
  final int? selectedSemesterId;

  const AddClassScreen({super.key, this.selectedSemesterId});

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

  // Method to select time
  Future<void> _selectTime(
      BuildContext context, TextEditingController controller) async {
    // Parse the existing time from the controller, or use a default time
    TimeOfDay initialTime;
    if (controller.text.isNotEmpty) {
      try {
        final parsedTime = DateFormat.jm()
            .parse(controller.text); // Parse time from "h:mm a" format
        initialTime =
            TimeOfDay(hour: parsedTime.hour, minute: parsedTime.minute);
      } catch (e) {
        initialTime =
            TimeOfDay(hour: 12, minute: 0); // Fallback in case of parsing error
      }
    } else {
      initialTime = TimeOfDay(hour: 12, minute: 0); // Default time
    }

    // Show the time picker with the initial time
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null) {
      setState(() {
        controller.text = picked.format(context); // Update the controller text
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
      final adjustedHour =
          (isPM && hour != 12) ? hour + 12 : (hour == 12 && !isPM ? 0 : hour);

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
        SnackBar(
            content: Text(
          'Please fill in all fields!',
          style: GoogleFonts.openSans(fontSize: 14),
        )),
      );
      return;
    }

    if (!_isValidTimeRange(startTime!, endTime!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
          'Start Time must be before End Time.',
          style: GoogleFonts.openSans(fontSize: 14),
        )),
      );
      return;
    }

    try {
      provider.activeSemesterId ??= selectedSemesterId;

      await provider.addClassScheduleWithSubject(
          subjectCode: subjectCode,
          subjectTitle: subjectTitle,
          semesterId: selectedSemesterId!,
          dayOfWeek: _selectedDay!,
          startTime: startTime,
          endTime: endTime,
          room: room);

      // Update the selected semester and fetch class schedules
      onAddClassSuccess(context, selectedSemesterId!);

      // After validation and adding logic
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 24),
              const SizedBox(width: 8),
              Text('Class Schedule added successfully',
                  style:
                      GoogleFonts.openSans(fontSize: 16, color: Colors.white)),
            ],
          ),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height * 0.4,
            left: 50,
            right: 50,
            top: 100,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Color(0xFF50B6FF).withOpacity(0.8),
          elevation: 10,
        ),
      );

      Navigator.pop(context, selectedSemesterId);
      // Clear fields after adding
      _clearFields();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, color: Colors.white, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Failed to add class schedule 1: $error',
                  style:
                      GoogleFonts.openSans(fontSize: 16, color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height * 0.4, // Moves to center
            left: 50,
            right: 50,
            top: 100,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // Square shape
          ),
          backgroundColor: Colors.red, // Error background color
          elevation: 10,
        ),
      );
    }
  }

  void onAddClassSuccess(BuildContext context, int newSemesterId) {
    final provider = Provider.of<ClassScheduleProvider>(context, listen: false);

    provider.activeSemesterId = newSemesterId;

    provider.fetchClassSchedules(selectedSemesterId: provider.activeSemesterId);
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
    final semesterProvider =
        Provider.of<SemesterProvider>(context, listen: false);
    semesterProvider.fetchSemesters().then((_) {
      setState(() {
        // Set default value if there are semesters available
        if (semesterProvider.semesters.isNotEmpty) {
          // Select the first semester
          selectedSemester =
              "${semesterProvider.semesters[0]['acad_year_start']} - ${semesterProvider.semesters[0]['acad_year_end']} ${semesterProvider.semesters[0]['semester']}";

          final defaultSemester = semesterProvider.semesters.first;
          selectedSemesterId = defaultSemester['semester_id'];

          // Log the selected semester
          print("Default selected semester: $selectedSemester");
          print("Default selected semester ID: $selectedSemesterId");
        }
      });
    });

    // Add listener for subject code controller to auto-fill subject title
    _subjectCodeController.addListener(() {
      final subjectProvider =
          Provider.of<ClassScheduleProvider>(context, listen: false);
      String subjectCode = _subjectCodeController.text.trim();

      if (subjectCode.isNotEmpty) {
        subjectProvider.fetchSubjectDetails(subjectCode).then((_) {
          setState(() {
            if (subjectProvider.selectedSubject != null) {
              _subjectTitleController.text =
                  subjectProvider.selectedSubject!.subjectTitle;
            } else {
              _subjectTitleController.clear(); // Clear if no subject is found
            }
          });
        }).catchError((error) {
          print("Error fetching subject details: $error");
          _subjectTitleController.clear();
        });
      } else {
        setState(() {
          _subjectTitleController.clear();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Class Schedule',
          style: GoogleFonts.openSans(
              fontWeight: FontWeight.bold, color: Color(0xFF173F70)),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Color(0xFFFFFFFF),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomWidgets.buildTitle(
                        'Subject Code',
                      ),
                      SizedBox(height: 15),
                      CustomWidgets.buildTextField(
                        _subjectCodeController,
                        'Subject Code',
                        style: GoogleFonts.openSans(),
                      ),
                      SizedBox(height: 15),
                      CustomWidgets.buildTitle(
                        'Subject Title',
                      ),
                      const SizedBox(height: 15),
                      CustomWidgets.buildTextField(
                        _subjectTitleController,
                        'Subject Title',
                        style: GoogleFonts.openSans(),
                      ),
                      SizedBox(height: 15),
                      CustomWidgets.buildTitle(
                        'Semester',
                      ),
                      const SizedBox(height: 15),
                      CustomWidgets.buildDropdownField(
                        label: 'Choose Semester',
                        textStyle: GoogleFonts.openSans(
                          fontSize: 14,
                        ),
                        value: selectedSemester,
                        items: semesterItems,
                        onChanged: (value) {
                          setState(() {
                            if (value == '- Add Semester -') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AddSemesterScreen()),
                              ).then((_) => semesterProvider.fetchSemesters());
                            } else {
                              selectedSemester = value;

                              // Split data from value for firstWhere comparison
                              List<String> semesterParts =
                                  selectedSemester!.split(' ');
                              int acadYearStart = int.parse(semesterParts[0]);
                              int acadYearEnd = int.parse(semesterParts[2]);
                              String semesterType =
                                  "${semesterParts[3]} ${semesterParts[4]}";

                              final selectedSemesterMap =
                                  semesterProvider.semesters.firstWhere(
                                (semester) {
                                  return semester['acad_year_start'] ==
                                          acadYearStart &&
                                      semester['acad_year_end'] ==
                                          acadYearEnd &&
                                      semester['semester'] == semesterType;
                                },
                                orElse: () =>
                                    {}, // Return null if no match is found
                              );
                              selectedSemesterId =
                                  selectedSemesterMap['semester_id'];
                              print(
                                  "Found semester ID: ${selectedSemesterMap['semester_id']}");
                            }
                          });
                        },
                        backgroundColor: const Color(0xFFF5F5F5),
                        labelColor: Colors.black,
                        textColor: Colors.black,
                        borderRadius: 30.0,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        fontSize: 14.0,
                      ),
                      const SizedBox(height: 15),
                      CustomWidgets.buildTitle(
                        'Day of the Week',
                      ),
                      SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          for (var day in ['S', 'M', 'T', 'W', 'Th', 'F', 'Sa'])
                            DayButton(
                              day: day,
                              isSelected: _selectedDay ==
                                  dayAbbreviationToFull[
                                      day], // Match full day name
                              onTap: () {
                                setState(() {
                                  if (_selectedDay ==
                                      dayAbbreviationToFull[day]) {
                                    _selectedDay = null;
                                  } else {
                                    _selectedDay = dayAbbreviationToFull[day];
                                  }
                                });
                              },
                            ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      CustomWidgets.buildTitle(
                        'Start and End Time',
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
                              (context) =>
                                  _selectTime(context, _endTimeController),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      CustomWidgets.buildTitle(
                        'Room',
                      ),
                      const SizedBox(height: 16),
                      CustomWidgets.buildTextField(_roomController, 'Room',
                          style: GoogleFonts.openSans(
                            fontSize: 16,
                            color: Colors.black,
                          )),
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
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 120),
                  ),
                  child: Text('Add Schedule',
                      style: GoogleFonts.openSans(
                        fontSize: 16,
                        color: Colors.white,
                      )),
                ),
              ),
            ],
          );
        },
      ),
      resizeToAvoidBottomInset: false,
    );
  }

  @override
  void dispose() {
    // Dispose controllers and clean up listeners
    _subjectCodeController.dispose();
    _subjectTitleController.dispose();
    _roomController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();

    // Always call super.dispose()
    super.dispose();
  }
}
