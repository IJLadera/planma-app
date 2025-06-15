import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:planma_app/Providers/class_schedule_provider.dart';
import 'package:planma_app/Providers/semester_provider.dart';
import 'package:planma_app/models/class_schedules_model.dart';
import 'package:planma_app/subject/semester/add_semester.dart';
import 'package:planma_app/subject/widget/widget.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class EditClass extends StatefulWidget {
  final ClassSchedule classSchedule;

  const EditClass({Key? key, required this.classSchedule}) : super(key: key);

  @override
  _EditClassState createState() => _EditClassState();
}

class _EditClassState extends State<EditClass> {
  late TextEditingController _subjectCodeController;
  late TextEditingController _subjectTitleController;
  late TextEditingController _roomController;
  late TextEditingController _startTimeController;
  late TextEditingController _endTimeController;

  String? selectedSemester;
  int? selectedSemesterId;
  String? selectedDay;

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
      final format =
          RegExp(r'^(\d{1,2}):(\d{2})\s?(AM|PM)$', caseSensitive: false);
      final match = format.firstMatch(timeString.trim());

      if (match == null) {
        throw FormatException('Invalid time format: $timeString');
      }

      final hour = int.parse(match.group(1)!);
      final minute = int.parse(match.group(2)!);
      final period = match.group(3)!.toLowerCase();

      final adjustedHour = (period == 'pm' && hour != 12)
          ? hour + 12
          : (hour == 12 && period == 'am' ? 0 : hour);

      return TimeOfDay(hour: adjustedHour, minute: minute);
    } catch (e) {
      print('Error parsing time: $e');
      return null;
    }
  }

  /// Converts a string like "HH:mm:ss" to "h:mm a" (for display)
  String _formatTimeForDisplay(String time24) {
    final timeParts = time24.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    final timeOfDay = TimeOfDay(hour: hour, minute: minute);

    // Format to "H:mm a"
    final now = DateTime.now();
    final dateTime = DateTime(
      now.year,
      now.month,
      now.day,
      timeOfDay.hour,
      timeOfDay.minute,
    );
    return DateFormat.jm().format(dateTime); // Requires intl package
  }

  @override
  void initState() {
    super.initState();

    // Pre-fill fields with current class details
    _subjectCodeController =
        TextEditingController(text: widget.classSchedule.subjectCode);
    _subjectTitleController =
        TextEditingController(text: widget.classSchedule.subjectTitle);
    _roomController = TextEditingController(text: widget.classSchedule.room);
    _startTimeController = TextEditingController(
      text: _formatTimeForDisplay(widget.classSchedule.scheduledStartTime),
    );
    _endTimeController = TextEditingController(
      text: _formatTimeForDisplay(widget.classSchedule.scheduledEndTime),
    );

    print(_formatTimeForDisplay(widget.classSchedule.scheduledStartTime));
    print(_formatTimeForDisplay(widget.classSchedule.scheduledEndTime));

    selectedSemesterId = widget.classSchedule.semesterId;
    selectedDay = widget.classSchedule.dayOfWeek;

    final semesterProvider =
        Provider.of<SemesterProvider>(context, listen: false);

    // Fetch semesters and set the selected semester
    semesterProvider.fetchSemesters().then((_) {
      setState(() {
        if (semesterProvider.semesters.isNotEmpty) {
          // Find the semester that matches `selectedSemesterId`
          final matchedSemester = semesterProvider.semesters.firstWhere(
            (semester) => semester['semester_id'] == selectedSemesterId,
            orElse: () => {},
          );

          if (matchedSemester != null) {
            selectedSemester =
                "${matchedSemester['acad_year_start']} - ${matchedSemester['acad_year_end']} ${matchedSemester['semester']}";
            print("Pre-selected semester: $selectedSemester");
          } else {
            // Fallback to the first semester if no match is found
            final defaultSemester = semesterProvider.semesters.first;
            selectedSemester =
                "${defaultSemester['acad_year_start']} - ${defaultSemester['acad_year_end']} ${defaultSemester['semester']}";
            selectedSemesterId = defaultSemester['semester_id'];
            print("Default selected semester: $selectedSemester");
          }
        }
      });
    });

    // Add listener for subject code controller to auto-fill subject title
    _subjectCodeController.addListener(() {
      final subjectProvider =
          Provider.of<ClassScheduleProvider>(context, listen: false);
      final semesterProvider =
          Provider.of<SemesterProvider>(context, listen: false);

      String subjectCode = _subjectCodeController.text.trim();

      if (subjectCode.isNotEmpty) {
        subjectProvider.fetchSubjectDetails(subjectCode).then((_) {
          if (subjectProvider.selectedSubject != null) {
            final subject = subjectProvider.selectedSubject!;
            setState(() {
              _subjectTitleController.text = subject.subjectTitle;

              // Auto-fill semester dropdown based on subject's semester
              final semester = semesterProvider.semesters.firstWhere(
                (sem) => sem['semester_id'] == subject.semesterId,
                orElse: () => <String, dynamic>{},
              );

              if (semester != null) {
                selectedSemesterId = semester['semester_id'];
                selectedSemester =
                    "${semester['acad_year_start']} - ${semester['acad_year_end']} ${semester['semester']}";
              }
            });
          } else {
            setState(() {
              _subjectTitleController.clear();
              selectedSemesterId = null;
              selectedSemester = null;
            });
          }
        }).catchError((error) {
          print("Error fetching subject details: $error");
          setState(() {
            _subjectTitleController.clear();
            selectedSemesterId = null;
            selectedSemester = null;
          });
        });
      } else {
        setState(() {
          _subjectTitleController.clear();
          selectedSemesterId = null;
          selectedSemester = null;
        });
      }
    });
  }

  // Method to handle editing a class
  void _editClassSchedule(BuildContext context) async {
    final provider = Provider.of<ClassScheduleProvider>(context, listen: false);

    String subjectCode = _subjectCodeController.text.trim();
    String subjectTitle = _subjectTitleController.text.trim();
    String startTimeString = _startTimeController.text.trim();
    String endTimeString = _endTimeController.text.trim();
    String room = _roomController.text.trim();

    print(startTimeString);
    print(endTimeString);

    // Convert String to TimeOfDay
    final startTime = _stringToTimeOfDay(startTimeString);
    final endTime = _stringToTimeOfDay(endTimeString);

    print('formatted: $startTime');
    print('formatted: $endTime');

    if (selectedSemesterId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
          'Please select a semester!',
          style: GoogleFonts.openSans(fontSize: 14),
        )),
      );
      return;
    }

    if (widget.classSchedule.classschedId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
          'Class Schedule ID is missing!',
          style: GoogleFonts.openSans(fontSize: 14),
        )),
      );
      return;
    }

    if (subjectCode.isEmpty ||
        subjectTitle.isEmpty ||
        room.isEmpty ||
        startTimeString.isEmpty ||
        endTimeString.isEmpty ||
        selectedDay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
          'Please fill in all fields!',
          style: GoogleFonts.openSans(fontSize: 14),
        )),
      );
      return;
    }

    if (startTime == null || endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
          'Invalid time format. Use "h:mm AM/PM".',
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
      print('Starting to update schedule...');
      await provider.updateClassSchedule(
          classschedId: widget.classSchedule.classschedId!,
          subjectCode: subjectCode,
          subjectTitle: subjectTitle,
          semesterId: selectedSemesterId!,
          dayOfWeek: selectedDay!,
          startTime: startTime,
          endTime: endTime,
          room: room);
      print('Schedule updated successfully!');

      // After validation and adding logic
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 22),
              const SizedBox(width: 8),
              Text('Class Schedule updated successfully',
                  style:
                      GoogleFonts.openSans(fontSize: 15, color: Colors.white)),
            ],
          ),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height * 0.4,
            left: 10,
            right: 10,
            top: 100,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Color(0xFF50B6FF).withOpacity(0.8),
          elevation: 10,
        ),
      );
      //Text('Failed to update class schedule: $error')

      Navigator.pop(context);
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
                  'Failed to update class schedule: $error',
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
            bottom: MediaQuery.of(context).size.height * 0.4,
            left: 10,
            right: 10,
            top: 100,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.red,
          elevation: 10,
        ),
      );
    }
  }

  bool _isValidTimeRange(TimeOfDay startTime, TimeOfDay endTime) {
    return startTime.hour < endTime.hour ||
        (startTime.hour == endTime.hour && startTime.minute < endTime.minute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Class Schedule',
          style: GoogleFonts.openSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF173F70)),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Color(0xFFFFFFFF),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Consumer<SemesterProvider>(
          builder: (context, semesterProvider, child) {
            // Prepare the dropdown list of semesters
            List<Map<String, dynamic>> semesters = semesterProvider.semesters;
            List<String> semesterItems = semesters
                .map((semester) =>
                    "${semester['acad_year_start']} - ${semester['acad_year_end']} ${semester['semester']}")
                .toList();
            semesterItems
                .add('- Add Semester -'); // Add option for new semester
            print('Semester Items: $semesterItems');

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomWidgets.buildTitle('Subject Code'),
                        const SizedBox(height: 12),
                        CustomWidgets.buildTextField(
                            _subjectCodeController, 'Subject Code'),
                        const SizedBox(height: 12),
                        CustomWidgets.buildTitle('Subject Title'),
                        const SizedBox(height: 12),
                        CustomWidgets.buildTextField(
                            _subjectTitleController, 'Subject Title'),
                        const SizedBox(height: 12),
                        CustomWidgets.buildTitle('Semester'),
                        const SizedBox(height: 12),
                        CustomWidgets.buildDropdownField(
                          label: 'Select Semester',
                          value: selectedSemester,
                          items: semesterItems,
                          onChanged: (value) {
                            setState(() {
                              if (value == '- Add Semester -') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          AddSemesterScreen()),
                                ).then(
                                    (_) => semesterProvider.fetchSemesters());
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

                                if (selectedSemesterMap != null) {
                                  selectedSemesterId =
                                      selectedSemesterMap['semester_id'];
                                  print(
                                      "Found semester ID: ${selectedSemesterMap['semester_id']}");
                                } else {
                                  print("No matching semester found");
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
                        const SizedBox(height: 12),
                        Text(
                          'Day of the Week',
                          style: GoogleFonts.openSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF173F70),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            for (var day in [
                              'S',
                              'M',
                              'T',
                              'W',
                              'Th',
                              'F',
                              'Sa'
                            ])
                              DayButton(
                                day: day,
                                isSelected: selectedDay ==
                                    dayAbbreviationToFull[
                                        day], // Match full day name
                                onTap: () {
                                  setState(() {
                                    if (selectedDay ==
                                        dayAbbreviationToFull[day]) {
                                      selectedDay = null;
                                    } else {
                                      selectedDay = dayAbbreviationToFull[day];
                                    }
                                  });
                                },
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        CustomWidgets.buildTitle('Start and End Time'),
                        const SizedBox(height: 12),
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
                        const SizedBox(height: 12),
                        CustomWidgets.buildTitle('Room'),
                        const SizedBox(height: 12),
                        CustomWidgets.buildTextField(_roomController, 'Room'),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14.0, vertical: 20.0),
                  child: ElevatedButton(
                    onPressed: () => _editClassSchedule(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF173F70),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 80),
                    ),
                    child: Text(
                      'Edit Class Schedule',
                      style: GoogleFonts.openSans(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      resizeToAvoidBottomInset: false,
    );
  }

  @override
  void dispose() {
    _subjectCodeController.dispose();
    _subjectTitleController.dispose();
    _roomController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }
}
