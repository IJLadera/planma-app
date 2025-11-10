import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:planma_app/event/widget/widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:planma_app/models/events_model.dart';
import 'package:provider/provider.dart';
import 'package:planma_app/Providers/events_provider.dart';

class EditEvent extends StatefulWidget {
  final Event event;
  const EditEvent({super.key, required this.event});

  @override
  _EditEvent createState() => _EditEvent();
}

class _EditEvent extends State<EditEvent> {
  late TextEditingController _eventNameController;
  late TextEditingController _descriptionController;
  late TextEditingController _eventLocationController;
  late TextEditingController _startTimeController;
  late TextEditingController _endTimeController;

  DateTime? _scheduledDate;
  String? _selectedEventType;
  final List<String> _EventType = ['Academic', 'Personal'];
  bool _isLoading = false;

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

    // Pre-fill fields with current event details
    _eventNameController = TextEditingController(text: widget.event.eventName);
    _descriptionController =
        TextEditingController(text: widget.event.eventDesc);
    _eventLocationController =
        TextEditingController(text: widget.event.location);
    _startTimeController = TextEditingController(
        text: _formatTimeForDisplay(widget.event.scheduledStartTime));
    _endTimeController = TextEditingController(
        text: _formatTimeForDisplay(widget.event.scheduledEndTime));

    print(_formatTimeForDisplay(widget.event.scheduledStartTime));
    print(_formatTimeForDisplay(widget.event.scheduledEndTime));

    _scheduledDate = widget.event.scheduledDate;
    _selectedEventType = widget.event.eventType;
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
                overflow: TextOverflow.ellipsis,
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

  void _editEvent(BuildContext context) async {
    final provider = Provider.of<EventsProvider>(context, listen: false);

    String eventName = _eventNameController.text.trim();
    String? rawEventDescription = _descriptionController.text.trim();
    String? normalizedEventDescription =
        rawEventDescription.isEmpty ? null : rawEventDescription;
    String location = _eventLocationController.text.trim();
    String startTimeString = _startTimeController.text.trim();
    String endTimeString = _endTimeController.text.trim();

    // Convert String  to TimeOfDay
    final startTime = _stringToTimeOfDay(startTimeString);
    final endTime = _stringToTimeOfDay(endTimeString);

    if (eventName.isEmpty) {
      _showError(context, "Event name is required.");
    }
    if (location.isEmpty) {
      _showError(context, 'Location is required.');
      return;
    }
    if (_scheduledDate == null) {
      _showError(context, 'Please select a scheduled date.');
      return;
    }
    if (startTimeString.isEmpty || startTime == null) {
      _showError(context, 'Please enter a valid start time.');
      return;
    }
    if (endTimeString.isEmpty || endTime == null) {
      _showError(context, 'Please enter a valid end time.');
      return;
    }
    if (!_isValidTimeRange(startTime, endTime)) {
      _showError(context, 'Start time must be before end time.');
      return;
    }
    if (_selectedEventType == null) {
      _showError(context, 'Please select an event type.');
      return;
    }

    if (!_isValidTimeRange(startTime, endTime)) {
      _showError(context, "Start time must be before end time.");
      return;
    }

    try {
      print('Starting to update event...');
      await provider.updateEvent(
        eventId: widget.event.eventId!,
        eventName: eventName,
        eventDesc: normalizedEventDescription,
        location: location,
        scheduledDate: _scheduledDate!,
        startTime: startTime,
        endTime: endTime,
        eventType: _selectedEventType!,
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
              Text('Event Updated Successfully',
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
      String errorMessage;

      if (error.toString().contains('Scheduling overlap')) {
        errorMessage = 'This timeslot is already occupied';
      } else if (error.toString().contains('Duplicate event entry detected')) {
        errorMessage = 'This event already exists.';
      } else {
        errorMessage = 'Failed to update event: $error';
      }
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
          'Edit Event',
          style: GoogleFonts.openSans(
            fontSize: 20,
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
                  CustomWidgets.buildTitle(
                    'Event Name',
                  ),
                  const SizedBox(height: 12),
                  CustomWidgets.buildTextField(
                      _eventNameController, 'Event Name'),
                  SizedBox(height: 12),
                  CustomWidgets.buildTitle(
                    'Description (optional)',
                  ),
                  const SizedBox(height: 12), // Increased space
                  CustomWidgets.buildTextField(
                      _descriptionController, 'Description'),
                  SizedBox(height: 12),
                  CustomWidgets.buildTitle(
                    'Location',
                  ),
                  const SizedBox(height: 12),
                  CustomWidgets.buildTextField(
                      _eventLocationController, 'Location'),
                  SizedBox(height: 12),
                  CustomWidgets.buildTitle(
                    'Scheduled Date',
                  ),
                  const SizedBox(height: 12),
                  CustomWidgets.buildDateTile('Scheduled Date', _scheduledDate,
                      context, true, _selectDate),
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
                  SizedBox(height: 12),
                  CustomWidgets.buildTitle(
                    'Event Type',
                  ),
                  const SizedBox(height: 12),
                  CustomWidgets.buildDropdownField(
                    label: 'Choose Event Type',
                    value: _selectedEventType,
                    items: _EventType,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedEventType = value;
                      });
                    },
                    backgroundColor: const Color(0xFFF5F5F5),
                    borderRadius: 30.0,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    fontSize: 14.0,
                  )
                ],
              ),
            )),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true; // Show loading indicator
                  });
                  _editEvent;
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF173F70),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 100),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Edit Event',
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
    _eventNameController.dispose();
    _descriptionController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();

    // Always call super.dispose()
    super.dispose();
  }
}
