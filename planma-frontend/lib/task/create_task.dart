import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:planma_app/Providers/class_schedule_provider.dart';
import 'package:planma_app/Providers/semester_provider.dart';
import 'package:planma_app/Providers/task_provider.dart';
import 'package:planma_app/task/widget/widgets.dart';
import 'package:provider/provider.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  _CreateTaskState createState() => _CreateTaskState();
}

class _CreateTaskState extends State<AddTaskScreen> {
  final _taskNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();
  final _scheduledDateController = TextEditingController();
  final _deadlineDateController = TextEditingController();

  DateTime? _scheduledDate;
  DateTime? _deadline;
  int? _subject;

  // Method to select date
  Future<void> _selectDate(BuildContext context, bool isScheduledDate) async {
    final currentDate = isScheduledDate ? _scheduledDate : _deadline;

    final picked = await showDatePicker(
      context: context,
      initialDate: currentDate ?? DateTime.now(), // Use selected date if exists
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    final dateFormat = DateFormat('yyyy-MM-dd');

    if (picked != null) {
      setState(() {
        if (isScheduledDate) {
          _scheduledDate = picked;
          _scheduledDateController.text = dateFormat.format(picked);
        } else {
          _deadline = picked;
          _deadlineDateController.text = dateFormat.format(picked);
        }
      });
    }
  }

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
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.openSans(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 100),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _submitTask(BuildContext context) async {
    final provider = Provider.of<TaskProvider>(context, listen: false);
    final subjects = Provider.of<ClassScheduleProvider>(context, listen: false).subjects;

    String taskName = _taskNameController.text.trim();
    String? rawTaskDescription = _descriptionController.text.trim();
    String? normalizedTaskDescription = rawTaskDescription.isEmpty ? null : rawTaskDescription;
    String startTimeString = _startTimeController.text.trim();
    String endTimeString = _endTimeController.text.trim();
    final startTime = _stringToTimeOfDay(startTimeString);
    final endTime = _stringToTimeOfDay(endTimeString);

    // Validate fields individually
    if (taskName.isEmpty) {
      _showError(context, "Task name is required.");
      return;
    }
    if (rawTaskDescription.isEmpty) {
      _showError(context, "Task description is required.");
      return;
    }
    if (_scheduledDate == null) {
      _showError(context, "Please select a scheduled date.");
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
    if (_deadline == null) {
      _showError(context, "Please set a deadline.");
      return;
    }
    if (_subject == null) {
      _showError(context, "Please select a subject.");
      return;
    }

    if (!_isValidTimeRange(startTime, endTime)) {
      _showError(context, "Start time must be before end time.");
      return;
    }

    final selectedSubject = subjects.firstWhere(
      (subject) => subject.subjectId == _subject,
      orElse: () => throw Exception("Selected subject not found."),
    );
    try {
      await provider.addTask(
        taskName: taskName,
        taskDesc: normalizedTaskDescription,
        scheduledDate: _scheduledDate!,
        startTime: startTime,
        endTime: endTime,
        deadline: _deadline!,
        subject: selectedSubject,
      );

      // Success Snackbar
      // After validation and adding logic

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 10),
              Center(
                child: Text(
                  'Task added successfully!',
                  style: GoogleFonts.openSans(color: Colors.white),
                ),
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

      Navigator.pop(context);
      _clearFields();
    } catch (error) {
      String errorMessage;

      if (error.toString().contains('Scheduling overlap')) {
        errorMessage = 'This time slot overlaps with another task.';
      } else if (error.toString().contains('Duplicate task entry detected')) {
        errorMessage = 'This task already exists.';
      } else {
        errorMessage = 'Failed: ${error.toString()}';
      }

      _showError(context, errorMessage);
    }
  }

  // Valid Time Range Check
  bool _isValidTimeRange(TimeOfDay startTime, TimeOfDay endTime) {
    return startTime.hour < endTime.hour ||
        (startTime.hour == endTime.hour && startTime.minute < endTime.minute);
  }

  // Clear fields after submit
  void _clearFields() {
    _taskNameController.clear();
    _descriptionController.clear();
    _startTimeController.clear();
    _endTimeController.clear();
    _scheduledDate = null;
    _deadline = null;
    _subject = null;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    // Fetch semesters and subjects when the screen loads
    final semesterProvider =
        Provider.of<SemesterProvider>(context, listen: false);
    final classScheduleProvider =
        Provider.of<ClassScheduleProvider>(context, listen: false);

    semesterProvider.fetchSemesters().then((_) {
      // Fetch subjects based on the active semester (determined in ClassScheduleProvider)
      classScheduleProvider.fetchSubjects(semesterProvider).then((_) {
        print("Subjects successfully fetched for the active semester.");
      }).catchError((error) {
        print("Error fetching subjects 1: $error");
      });
    }).catchError((error) {
      print("Error fetching semesters: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Task',
          style: GoogleFonts.openSans(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Color(0xFF173F70)),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Color(0xFFFFFFFF),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    CustomWidgets.buildTitle(
                      'Task Name',
                    ),
                    const SizedBox(height: 12),
                    CustomWidgets.buildTextField(
                      _taskNameController,
                      'Task Name',
                      style: GoogleFonts.openSans(),
                    ),
                    const SizedBox(height: 12),
                    CustomWidgets.buildTitle('Description'),
                    const SizedBox(height: 12),
                    CustomWidgets.buildTextField(
                      _descriptionController,
                      'Description',
                      style: GoogleFonts.openSans(),
                    ),
                    const SizedBox(height: 12),
                    CustomWidgets.buildTitle('Scheduled Date'),
                    const SizedBox(height: 12),
                    CustomWidgets.buildDateTile(
                      'Scheduled Date',
                      _scheduledDate,
                      context,
                      true,
                      (context, date) => _selectDate(context, true),
                    ),
                    const SizedBox(height: 12),
                    CustomWidgets.buildTitle('Start and End Time'),
                    const SizedBox(height: 12),
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
                              openEndTimeAfter: true,
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
                    const SizedBox(height: 12),
                    CustomWidgets.buildTitle('Deadline'),
                    const SizedBox(height: 12),
                    CustomWidgets.buildDateTile(
                      'Deadline',
                      _deadline,
                      context,
                      false,
                      (context, date) => _selectDate(context, false),
                    ),
                    const SizedBox(height: 12),
                    CustomWidgets.buildTitle('Subject'),
                    const SizedBox(height: 12),
                    CustomWidgets.buildDropdownField(
                      label: 'Choose Subject',
                      value: _subject,
                      items: Provider.of<ClassScheduleProvider>(context)
                          .subjects
                          .map((subject) => DropdownMenuItem(
                                value: subject.subjectId,
                                child: Text(subject.subjectCode),
                              ))
                          .toList(),
                      onChanged: (int? value) {
                        setState(() {
                          _subject = value;
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
                  ],
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              child: ElevatedButton(
                onPressed: () => _submitTask(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF173F70),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 100),
                ),
                child: Text(
                  'Create Task',
                  style: GoogleFonts.openSans(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      resizeToAvoidBottomInset: false,
    );
  }

  @override
  void dispose() {
    // Dispose controllers and clean up listeners
    _taskNameController.dispose();
    _descriptionController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();

    // Always call super.dispose()
    super.dispose();
  }
}
