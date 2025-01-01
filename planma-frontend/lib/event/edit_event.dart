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
        final parsedTime = DateFormat.jm().parse(controller.text); // Parse time from "h:mm a" format
        initialTime = TimeOfDay(hour: parsedTime.hour, minute: parsedTime.minute);
      } catch (e) {
        initialTime = TimeOfDay(hour: 12, minute: 0); // Fallback in case of parsing error
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

  void _editEvent(BuildContext context) async {
    final provider = Provider.of<EventsProvider>(context, listen: false);

    String eventName = _eventNameController.text.trim();
    String eventDesc = _descriptionController.text.trim();
    String location = _eventLocationController.text.trim();
    String startTimeString = _startTimeController.text.trim();
    String endTimeString = _endTimeController.text.trim();

    print(startTimeString);
    print(endTimeString);

    // Convert String  to TimeOfDay
    final startTime = _stringToTimeOfDay(startTimeString);
    final endTime = _stringToTimeOfDay(endTimeString);

    print('formatted: $startTime');
    print('formatted: $endTime');

    if (eventName.isEmpty ||
        eventDesc.isEmpty ||
        location.isEmpty ||
        _scheduledDate == null ||
        startTimeString.isEmpty ||
        endTimeString.isEmpty ||
        endTimeString.isEmpty ||
        _selectedEventType == null) {
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

    print('FROM UI:');
    print('Event Name: $eventName');
    print('event Description: $eventDesc');
    print('location: $location');
    print('Scheduled Date: $_scheduledDate');
    print('Start Time: $startTime');
    print('End Time: $endTime');
    print('eventType: $_selectedEventType');

    try {
      print('Starting to update task...');
      await provider.updateEvent(
        eventId: widget.event.eventId!,
        eventName: eventName,
        eventDesc: eventDesc,
        location: location,
        scheduledDate: _scheduledDate!,
        startTime: startTime,
        endTime: endTime,
        eventType: _selectedEventType!,
      );
      print('Event updated successfully!');

      // After validation and adding logic
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event updated successfully!')),
      );

      Navigator.pop(context);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update event: $error')),
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
            'Edit Event',
            style: GoogleFonts.openSans(
              fontSize: 20,
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
                  CustomWidgets.buildTitle(
                    'Event Name',
                  ),
                  const SizedBox(height: 12),
                  CustomWidgets.buildTextField(
                      _eventNameController, 'Event Name'),
                  SizedBox(height: 12),
                  CustomWidgets.buildTitle(
                    'Description',
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
                    label:
                        'Choose Event Type', // Updated the label for consistency
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
                onPressed: () => _editEvent(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF173F70),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 120),
                ),
                child: Text(
                  'Edit Event',
                  style: GoogleFonts.openSans(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}
