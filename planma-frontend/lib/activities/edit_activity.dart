import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:planma_app/Providers/activity_provider.dart';
import 'package:planma_app/activities/widget/widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:planma_app/models/activity_model.dart';
import 'package:provider/provider.dart';

class EditActivity extends StatefulWidget {
  final Activity activity;

  const EditActivity({super.key, required this.activity});

  @override
  _EditActivity createState() => _EditActivity();
}

class _EditActivity extends State<EditActivity> {
  late TextEditingController _activityNameController;
  late TextEditingController _activityDescriptionController;
  late TextEditingController _startTimeController;
  late TextEditingController _endTimeController;

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

    // Pre-fill fields with current activity details
    _activityNameController =
        TextEditingController(text: widget.activity.activityName);
    _activityDescriptionController =
        TextEditingController(text: widget.activity.activityDescription);
    _startTimeController = TextEditingController(
        text: _formatTimeForDisplay(widget.activity.scheduledStartTime));
    _endTimeController = TextEditingController(
        text: _formatTimeForDisplay(widget.activity.scheduledEndTime));

    print(_formatTimeForDisplay(widget.activity.scheduledStartTime));
    print(_formatTimeForDisplay(widget.activity.scheduledEndTime));

    _scheduledDate = widget.activity.scheduledDate;
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

  void _editActivity(BuildContext context) async {
    final provider = Provider.of<ActivityProvider>(context, listen: false);

    String activityName = _activityNameController.text.trim();
    String activityDescription = _activityDescriptionController.text.trim();
    String startTimeString = _startTimeController.text.trim();
    String endTimeString = _endTimeController.text.trim();

    // Convert String  to TimeOfDay
    final startTime = _stringToTimeOfDay(startTimeString);
    final endTime = _stringToTimeOfDay(endTimeString);

    if (activityName.isEmpty) {
      _showError(context, "Activity name is required.");
      return;
    }
    if (activityDescription.isEmpty) {
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
      print('Starting to update activity...');
      await provider.updateActivity(
        activityId: widget.activity.activityId!,
        activityName: activityName,
        activityDesc: activityDescription,
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

  bool _isValidTimeRange(TimeOfDay startTime, TimeOfDay endTime) {
    return startTime.hour < endTime.hour ||
        (startTime.hour == endTime.hour && startTime.minute < endTime.minute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Activity',
          style: GoogleFonts.openSans(
            color: Color(0xFF173F70),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
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
                    CustomWidgets.buildDateTile('Scheduled Date',
                        _scheduledDate, context, true, _selectDate),
                    const SizedBox(height: 12),
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
                onPressed: () => _editActivity(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF173F70),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 100),
                ),
                child: Text(
                  'Edit Activity',
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
    _activityNameController.dispose();
    _activityDescriptionController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();

    // Always call super.dispose()
    super.dispose();
  }
}
