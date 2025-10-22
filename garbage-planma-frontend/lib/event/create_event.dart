import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:planma_app/event/widget/widget.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:planma_app/Providers/events_provider.dart';

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({super.key});

  @override
  _AddEventScreen createState() => _AddEventScreen();
}

class _AddEventScreen extends State<AddEventScreen> {
  final _eventNameController = TextEditingController();
  final _eventDescController = TextEditingController();
  final _eventLocationController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();

  DateTime? _scheduledDate;
  String? _selectedEventType;
  final List<String> _eventTypes = ['Academic', 'Personal'];

  bool _isSubmitting = false;

  // Method to select date
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

  // Create event function
  Future<void> _createEvent() async {
    if (_isSubmitting) return; // Prevent duplicate submissions
    FocusScope.of(context).unfocus(); // Dismiss keyboard

    final provider = Provider.of<EventsProvider>(context, listen: false);

    String eventName = _eventNameController.text.trim();
    String location = _eventLocationController.text.trim();
    String? rawEventDescription = _eventDescController.text.trim();
    String? normalizedEventDescription = rawEventDescription.isEmpty ? null : rawEventDescription;
    String startTimeString = _startTimeController.text.trim();
    String endTimeString = _endTimeController.text.trim();

    // Convert String to TimeOfDay
    final startTime = _stringToTimeOfDay(startTimeString);
    final endTime = _stringToTimeOfDay(endTimeString);

    // Dynamic validation with specific error messages
    if (eventName.isEmpty) {
      _showError(context, 'Event name is required.');
      return;
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

    try {
      await provider.addEvent(
        eventName: eventName,
        eventDesc: normalizedEventDescription,
        location: location,
        scheduledDate: _scheduledDate!,
        startTime: startTime,
        endTime: endTime,
        eventType: _selectedEventType!,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Event created successfully!',
                  style: GoogleFonts.openSans(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF50B6FF),
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
        errorMessage =
            'This time slot overlaps with another event.';
      } else if (error.toString().contains('Duplicate event entry detected')) {
        errorMessage = 'This event already exists.';
      } else {
        errorMessage = 'Failed: $error';
      }

      _showError(context, errorMessage);
    }
  }

  // Valid Time Range Check
  bool _isValidTimeRange(TimeOfDay startTime, TimeOfDay endTime) {
    return startTime.hour < endTime.hour ||
        (startTime.hour == endTime.hour && startTime.minute < endTime.minute);
  }

  void _clearFields() {
    _eventNameController.clear();
    _eventDescController.clear();
    _startTimeController.clear();
    _endTimeController.clear();
    _scheduledDate = null;
    _selectedEventType = null;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Event',
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
                    const SizedBox(height: 12),
                    CustomWidgets.buildTitle(
                      'Description (optional)',
                    ),
                    const SizedBox(height: 12),
                    CustomWidgets.buildTextField(
                        _eventDescController, 'Description'),
                    const SizedBox(height: 12),
                    CustomWidgets.buildTitle(
                      'Location',
                    ),
                    const SizedBox(height: 12),
                    CustomWidgets.buildTextField(
                        _eventLocationController, 'Location'),
                    const SizedBox(height: 12),
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
                    const SizedBox(height: 12),
                    CustomWidgets.buildTitle(
                      'Event Type',
                    ),
                    const SizedBox(height: 12),
                    CustomWidgets.buildDropdownField(
                      label: 'Choose Event Type',
                      value: _selectedEventType,
                      items: _eventTypes,
                      onChanged: (String? value) {
                        setState(() {
                          _selectedEventType = value;
                        });
                      },
                      backgroundColor: const Color(0xFFF5F5F5),
                      borderRadius: 30.0,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 5),
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
                onPressed: _createEvent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF173F70),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 100),
                ),
                child: Text(
                  'Create Event',
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
}
