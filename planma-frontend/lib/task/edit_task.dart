import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:planma_app/Providers/class_schedule_provider.dart';
import 'package:planma_app/Providers/semester_provider.dart';
import 'package:planma_app/Providers/task_provider.dart';
import 'package:planma_app/models/tasks_model.dart';
import 'package:planma_app/task/widget/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class EditTask extends StatefulWidget {
  final Task task;

  const EditTask({super.key, required this.task});

  @override
  _EditTask createState() => _EditTask();
}

class _EditTask extends State<EditTask> {
  late TextEditingController _taskNameController;
  late TextEditingController _descriptionController;
  late TextEditingController _startTimeController;
  late TextEditingController _endTimeController;

  DateTime? _scheduledDate;
  DateTime? _deadline;
  int? _subject;

  // Method to select date
  Future<void> _selectDate(BuildContext context, bool isScheduledDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isScheduledDate) {
          _scheduledDate = picked;
        } else {
          _deadline = picked;
        }
      });
    }
  }

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

    // Pre-fill fields with current task details
    _taskNameController = TextEditingController(text: widget.task.taskName);
    _descriptionController =
        TextEditingController(text: widget.task.taskDescription);
    _startTimeController = TextEditingController(
        text: _formatTimeForDisplay(widget.task.scheduledStartTime));
    _endTimeController = TextEditingController(
        text: _formatTimeForDisplay(widget.task.scheduledEndTime));

    _scheduledDate = widget.task.scheduledDate;
    _deadline = widget.task.deadline;
    _subject = widget.task.subject?.subjectId;

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

  // Helper function to create snackbars
  SnackBar _buildSnackBar(
      {required IconData icon,
      required String text,
      required Color backgroundColor}) {
    return SnackBar(
      content: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.openSans(color: Colors.white, fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
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
      backgroundColor: backgroundColor,
      elevation: 10,
    );
  }

  void _editTask(BuildContext context) async {
    final provider = Provider.of<TaskProvider>(context, listen: false);
    final subjects =
        Provider.of<ClassScheduleProvider>(context, listen: false).subjects;

    String taskName = _taskNameController.text.trim();
    String? rawTaskDescription = _descriptionController.text.trim();
    String? normalizedTaskDescription = rawTaskDescription.isEmpty ? null : rawTaskDescription;
    String startTimeString = _startTimeController.text.trim();
    String endTimeString = _endTimeController.text.trim();

    // Convert String  to TimeOfDay
    final startTime = _stringToTimeOfDay(startTimeString);
    final endTime = _stringToTimeOfDay(endTimeString);

    if (taskName.isEmpty ||
        _scheduledDate == null ||
        startTimeString.isEmpty ||
        endTimeString.isEmpty ||
        _deadline == null ||
        _subject == null) {
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

    final selectedSubject =
        subjects.firstWhere((subject) => subject.subjectId == _subject);

    try {
      print('Starting to update task...');
      await provider.updateTask(
        taskId: widget.task.taskId!,
        taskName: taskName,
        taskDesc: normalizedTaskDescription,
        scheduledDate: _scheduledDate!,
        startTime: startTime,
        endTime: endTime,
        deadline: _deadline!,
        subject: selectedSubject,
      );

      // Success Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 24),
              const SizedBox(width: 8),
              Text('Task Updated Successfully',
                  style:
                      GoogleFonts.openSans(fontSize: 16, color: Colors.white)),
            ],
          ),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height * 0.4,
            left: 20,
            right: 20,
            top: 100,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Color(0xFF50B6FF).withOpacity(0.8),
          elevation: 10,
        ),
      );

      Navigator.pop(context);
    } catch (error) {
      String errorMessage = 'Failed to update task';

      if (error.toString().contains('Scheduling overlap')) {
        errorMessage =
            'Scheduling overlap: This time slot is already occupied.';
      } else if (error.toString().contains('Duplicate task entry detected')) {
        errorMessage = 'Duplicate task entry: This task already exists.';
      } else {
        errorMessage = 'Failed to update task: $error';
      }

      // Error Snackbar
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
                  'Failed to Update Task 1: $error',
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
            left: 20,
            right: 20,
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

  bool _isValidTimeRange(TimeOfDay startTime, TimeOfDay endTime) {
    return startTime.hour < endTime.hour ||
        (startTime.hour == endTime.hour && startTime.minute < endTime.minute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Task',
          style: GoogleFonts.openSans(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
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
                    _buildTitle('Task Name'),
                    const SizedBox(height: 12),
                    CustomWidgets.buildTextField(
                      _taskNameController,
                      'Task Name',
                    ),
                    const SizedBox(height: 12),
                    _buildTitle('Description'),
                    const SizedBox(height: 12),
                    CustomWidgets.buildTextField(
                      _descriptionController,
                      'Description',
                    ),
                    const SizedBox(height: 12),
                    _buildTitle('Scheduled Date'),
                    const SizedBox(height: 12),
                    CustomWidgets.buildDateTile(
                      'Scheduled Date',
                      _scheduledDate,
                      context,
                      true,
                      (context, date) => _selectDate(context, true),
                    ),
                    const SizedBox(height: 12),
                    _buildTitle('Start and End Time'),
                    const SizedBox(height: 12),
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
                    const SizedBox(height: 12),
                    _buildTitle('Deadline'),
                    const SizedBox(height: 12),
                    CustomWidgets.buildDateTile(
                      'Deadline',
                      _deadline,
                      context,
                      false,
                      (context, date) => _selectDate(context, false),
                    ),
                    const SizedBox(height: 12),
                    _buildTitle('Subject'),
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
                onPressed: () => _editTask(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF173F70),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 100),
                ),
                child: Text(
                  'Edit Task',
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

Widget _buildTitle(String title) {
  return Container(
    margin: const EdgeInsets.only(
        left: 16.0,
        top: 8.0,
        right: 16.0), // Adjust the margin values as needed
    alignment: Alignment.centerLeft, // Ensures the text starts from the left
    child: Text(
      title,
      style: GoogleFonts.openSans(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFF173F70),
      ),
    ),
  );
}
