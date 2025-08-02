import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:planma_app/activities/widget/widget.dart';
import 'package:provider/provider.dart';
import 'package:planma_app/Providers/activity_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class AddActivityScreen extends StatefulWidget {
  const AddActivityScreen({super.key});

  @override
  _AddActivityState createState() => _AddActivityState();
}

class _AddActivityState extends State<AddActivityScreen> {
  final _activityNameController = TextEditingController();
  final _activityDescriptionController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();

  DateTime? _scheduledDate;

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

  void _createActivity(BuildContext context) async {
    final provider = Provider.of<ActivityProvider>(context, listen: false);

    String activityName = _activityNameController.text.trim();
    String? rawActivityDescription = _activityDescriptionController.text.trim();
    String? normalizedActivityDescription = rawActivityDescription.isEmpty ? null : rawActivityDescription;
    String startTimeString = _startTimeController.text.trim();
    String endTimeString = _endTimeController.text.trim();

    // Convert String to TimeOfDay
    final startTime = _stringToTimeOfDay(startTimeString);
    final endTime = _stringToTimeOfDay(endTimeString);

    if (activityName.isEmpty ||
        _scheduledDate == null ||
        startTimeString.isEmpty ||
        endTimeString.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please fill out all fields',
            style: GoogleFonts.openSans(fontSize: 16),
          ),
        ),
      );
      return;
    }

    if (!_isValidTimeRange(startTime!, endTime!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Start Time must be before End Time.',
            style: GoogleFonts.openSans(fontSize: 16),
          ),
        ),
      );
      return;
    }

    try {
      await provider.addActivity(
          activityName: activityName,
          activityDesc: normalizedActivityDescription,
          scheduledDate: _scheduledDate!,
          startTime: startTime,
          endTime: endTime);

      // Success Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            mainAxisSize: MainAxisSize.min, // Make the row compact
            mainAxisAlignment: MainAxisAlignment.center, // Center the content
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Text(
                'Activity Created Successfully!',
                style: GoogleFonts.openSans(fontSize: 16, color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height * 0.4,
            left: 30,
            right: 30,
            top: 100,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // Make it a square
          ),
          backgroundColor: Color(0xFF50B6FF).withOpacity(0.8),
          elevation: 12, // Add shadow for better visibility
        ),
      );

      Navigator.pop(context);
      _clearFields();
    } catch (error) {
      String errorMessage = 'Failed to create activity';

      if (error.toString().contains('Scheduling overlap')) {
        errorMessage =
            'Scheduling overlap: This time slot is already occupied.';
      } else if (error
          .toString()
          .contains('Duplicate activity entry detected')) {
        errorMessage =
            'Duplicate activity entry: This activity already exists.';
      } else {
        errorMessage = 'Failed to create activity: $error';
      }

      // Error Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error,
                  color: Colors.white, size: 24), // Error icon
              const SizedBox(width: 8),
              Expanded(
                // Prevents text overflow
                child: Text(
                  'Failed To Create Activity (1): $error',
                  style:
                      GoogleFonts.openSans(color: Colors.white, fontSize: 16),
                  overflow: TextOverflow.ellipsis, // Handles long errors
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height * 0.4, // Moves to center
            left: 30,
            right: 30,
            top: 100,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // Square shape
          ),
          backgroundColor: Colors.red, // Error background color
          elevation: 10, // Adds shadow
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
    _activityNameController.clear();
    _activityDescriptionController.clear();
    _startTimeController.clear();
    _endTimeController.clear();
    _scheduledDate = null;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Activity',
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
                    'Activity Name',
                  ),
                  const SizedBox(height: 12),
                  CustomWidgets.buildTextField(
                      _activityNameController, 'Activity Name'),
                  SizedBox(height: 12),
                  CustomWidgets.buildTitle(
                    'Description',
                  ),
                  const SizedBox(height: 12),
                  CustomWidgets.buildTextField(
                      _activityDescriptionController, 'Description'),
                  SizedBox(height: 12),
                  CustomWidgets.buildTitle(
                    'Scheduled Date',
                  ),
                  const SizedBox(height: 12),
                  CustomWidgets.buildDateTile(
                      '', _scheduledDate, context, true, _selectDate),
                  SizedBox(height: 12),
                  CustomWidgets.buildTitle(
                    'Start and End Time',
                  ),
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
            )),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              child: ElevatedButton(
                onPressed: () => _createActivity(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF173F70),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 100),
                ),
                child: Text(
                  'Create Activity',
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

  @override
  void dispose() {
    // Dispose controllers and clean up listeners
    _activityNameController.dispose();
    _activityDescriptionController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();

    // Always call super.dispose()
    super.dispose();
  }
}
