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

    if (activityName.isEmpty) {
      _showError(context, "Activity name is required.");
      return;
    }
    if (rawActivityDescription.isEmpty) {
      _showError(context, "Activity description is required.");
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
    if (!_isValidTimeRange(startTime, endTime)) {
      _showError(context, "Start time must be before end time.");
      return;
    }

    try {
      await provider.addActivity(
          activityName: activityName,
          activityDesc: normalizedActivityDescription,
          scheduledDate: _scheduledDate!,
          startTime: startTime,
          endTime: endTime);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 10),
              Text(
                'Activity created successfully!',
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
        errorMessage = 'This time slot overlaps with another activity.';
      } else if (error
          .toString()
          .contains('Duplicate activity entry detected')) {
        errorMessage = 'This activity already exists.';
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
