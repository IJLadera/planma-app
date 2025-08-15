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
  final _scheduledDateController = TextEditingController();
  final _deadlineDateController = TextEditingController();

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
    BuildContext context,
    TextEditingController controller, {
    bool openEndTimeAfter = false,
    TextEditingController? endTimeController,
  }) async {
    TimeOfDay initialTime;
    if (controller.text.isNotEmpty) {
      try {
        final parsedTime = DateFormat.jm().parse(controller.text);
        initialTime =
            TimeOfDay(hour: parsedTime.hour, minute: parsedTime.minute);
      } catch (e) {
        initialTime = TimeOfDay.now();
      }
    } else {
      initialTime = TimeOfDay.now();
    }

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null) {
      setState(() {
        controller.text = picked.format(context);
      });

      // Immediately show End Time Picker after Start Time if needed
      if (openEndTimeAfter && endTimeController != null) {
        await _selectTime(context, endTimeController);
      }
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

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.openSans(color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 100),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        duration: const Duration(seconds: 3),
      ),
    );
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

    if (subjectCode.isEmpty) {
      _showError(context, "Subject code is required.");
      return;
    }
    if (subjectTitle.isEmpty) {
      _showError(context, "Subject title is required.");
      return;
    }
    if (room.isEmpty) {
      _showError(context, "Room is required.");
      return;
    }
    if (_selectedDay == null) {
      _showError(context, "Please select a day of the week.");
      return;
    }
    if (startTimeString.isEmpty || startTime == null) {
      _showError(context, "Please enter a valid start time.");
      return;
    }
    if (endTimeString.isEmpty || endTime == null) {
      _showError(context, "Please enter a valid end time.");
      return;
    }

    if (!_isValidTimeRange(startTime, endTime)) {
      _showError(context, "Start time must be before end time.");
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 10),
              Text(
                'Class schedule added successfully!',
                style: GoogleFonts.openSans(color: Colors.white),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 100),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          duration: const Duration(seconds: 3),
        ),
      );

      Navigator.pop(context, selectedSemesterId);
      // Clear fields after adding
      _clearFields();
    } catch (error) {
      String errorMessage;

      if (error.toString().contains('Duplicate class schedule')) {
        errorMessage = 'This class schedule already exists.';
      } else if (error.toString().contains('Scheduling overlap')) {
        errorMessage = 'This time slot overlaps with another class.';
      } else {
        errorMessage = 'Failed to add class schedule: ${error.toString()}';
      }
      _showError(context, errorMessage);
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

    // Fetch semesters when the screen loads
    semesterProvider.fetchSemesters().then((_) {
      if (semesterProvider.semesters.isEmpty) return;

      // CASE A: <AddClassScreen selectedSemesterId:…> was supplied by caller
      Map<String, dynamic>? preSelected;
      if (widget.selectedSemesterId != null) {
        preSelected = semesterProvider.semesters.firstWhere(
          (s) => s['semester_id'] == widget.selectedSemesterId,
          orElse: () => <String, dynamic>{},
        );
      }

      // CASE B: pick the most‑recent semester that has already started
      if (preSelected == null || preSelected.isEmpty) {
        final now = DateTime.now();

        // keep only semesters whose start date is ≤ today
        final valid = semesterProvider.semesters.where((s) {
          final start = DateTime.parse(s['sem_start_date']);
          return !start.isAfter(now); //  start ≤ now
        }).toList();

        // Sort by start date descending to get the most recent one
        valid.sort((a, b) => DateTime.parse(b['sem_start_date'])
            .compareTo(DateTime.parse(a['sem_start_date'])));

        // fallback to first if none match
        preSelected = valid.isNotEmpty
            ? valid.first
            : semesterProvider.semesters.reduce((a, b) =>
                DateTime.parse(a['sem_start_date'])
                        .isAfter(DateTime.parse(b['sem_start_date']))
                    ? a
                    : b);
      }

      setState(() {
        selectedSemesterId = preSelected!['semester_id'];
        selectedSemester =
            "${preSelected['acad_year_start']} - ${preSelected['acad_year_end']} ${preSelected['semester']}";
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Class Schedule',
          style: GoogleFonts.openSans(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF173F70),
          ),
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
                                (context) => _selectTime(
                                  context,
                                  _startTimeController,
                                  openEndTimeAfter:
                                      true, // OPTIONAL if your function supports it
                                  endTimeController: _endTimeController,
                                ),
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
                        CustomWidgets.buildTextField(
                          _roomController,
                          'Room',
                          style: GoogleFonts.openSans(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
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
                          vertical: 15, horizontal: 100),
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
