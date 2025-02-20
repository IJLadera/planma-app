import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:planma_app/Providers/goal_schedule_provider.dart';
import 'package:planma_app/goals/widget/widget.dart';
import 'package:provider/provider.dart';

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
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _scheduledDate = pickedDate;
      });
    }
  }

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

  void _submitForm(BuildContext context) async {
    final provider = Provider.of<GoalScheduleProvider>(context, listen: false);

    String startTimeString = _startTimeController.text.trim();
    String endTimeString = _endTimeController.text.trim();

    final startTime = _stringToTimeOfDay(startTimeString);
    final endTime = _stringToTimeOfDay(endTimeString);

    if (_scheduledDate == null ||
        startTimeString.isEmpty ||
        endTimeString.isEmpty) {
      // Show error dialog if any field is empty
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    if (!_isValidTimeRange(startTime!, endTime!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Start Time must be before End Time.')),
      );
      return;
    }

    try {
      await provider.addGoalSchedule(
        goalId: widget.goalId,
        scheduledDate: _scheduledDate!,
        startTime: startTime,
        endTime: endTime,
      );

      // Success Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        _buildSnackBar(
          icon: Icons.check_circle,
          text: 'Goal schedule created successfully!',
          backgroundColor: Color(0xFF50B6FF).withOpacity(0.8),
        ),
      );

      Navigator.pop(context);
      _clearFields();
    } catch (error) {
      String errorMessage = 'Failed to create goal schedule';

      if (error.toString().contains('Scheduling overlap')) {
        errorMessage =
            'Scheduling overlap: This time slot is already occupied.';
      } else if (error.toString().contains('Duplicate goal schedule entry detected')) {
        errorMessage = 'Duplicate goal schedule entry: This goal schedule already exists.';
      } else {
        errorMessage = 'Failed to create goal schedule: $error';
      }

      // Error Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        _buildSnackBar(
          icon: Icons.error,
          text: errorMessage,
          backgroundColor: Colors.red,
        ),
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
      body: Column(
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
                  CustomWidgets.buildDateTile('Scheduled Date', _scheduledDate,
                      context, true, _selectDate),
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
                          (context) => _selectTime(context, _endTimeController),
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
