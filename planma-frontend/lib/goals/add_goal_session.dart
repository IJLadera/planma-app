import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:planma_app/Providers/goal_schedule_provider.dart';
import 'package:planma_app/goals/widget/widget.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class AddGoalSession extends StatefulWidget {
  final String goalName;
  final int goalId;

  const AddGoalSession(
      {super.key, required this.goalName, required this.goalId});

  @override
  _AddGoalSession createState() => _AddGoalSession();
}

class _AddGoalSession extends State<AddGoalSession> {
  late TextEditingController _goalNameController;
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();

  DateTime? _scheduledDate;

  @override
  void initState() {
    super.initState();
    _goalNameController = TextEditingController(text: widget.goalName);
  }

  @override
  void dispose() {
    _goalNameController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  void _selectDate(BuildContext context, DateTime? initialDate) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(), // Use last selected date
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _scheduledDate = pickedDate; // Save selected date
      });
    }
  }

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

  void _submitForm(BuildContext context) async {
    final provider = Provider.of<GoalScheduleProvider>(context, listen: false);

    String startTimeString = _startTimeController.text.trim();
    String endTimeString = _endTimeController.text.trim();

    final startTime = _stringToTimeOfDay(startTimeString);
    final endTime = _stringToTimeOfDay(endTimeString);

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
    if (!_isValidTimeRange(startTime, endTime)) {
      _showError(context, "Start time must be before end time.");
      return;
    }

    try {
      await provider.addGoalSchedule(
        goalId: widget.goalId,
        scheduledDate: _scheduledDate!,
        startTime: startTime,
        endTime: endTime,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 10),
              Text(
                'Goal Session created successfully!',
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

      Navigator.pop(context);
      _clearFields();
    } catch (error) {
      String errorMessage;

      if (error.toString().contains('Scheduling overlap')) {
        errorMessage = 'This time slot overlaps with another goal session.';
      } else if (error
          .toString()
          .contains('Duplicate goal schedule entry detected')) {
        errorMessage = 'This goal session already exists.';
      } else {
        errorMessage = 'Failed to create goal session: $error';
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
    _scheduledDate = null;
    _startTimeController.clear();
    _endTimeController.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Goal Session',
          style: GoogleFonts.openSans(
            fontWeight: FontWeight.bold,
            color: Color(0xFF173F70),
          ),
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
                    _buildTitle('Goal Name'),
                    const SizedBox(height: 12),
                    CustomWidgets.buildTextField(
                      _goalNameController,
                      'Goal Name',
                      readOnly: true,
                    ),
                    const SizedBox(height: 12),
                    _buildTitle('Scheduled Date'),
                    const SizedBox(height: 12),
                    CustomWidgets.buildDateTile('Scheduled Date',
                        _scheduledDate, context, true, _selectDate),
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
                  ],
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              child: ElevatedButton(
                onPressed: () => _submitForm(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF173F70),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 100),
                ),
                child: Text(
                  'Add Goal Session',
                  style: GoogleFonts.openSans(
                    fontSize: 16,
                    color: Color(0xFFFFFFFF),
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
