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

  // Create event function
  Future<void> _createEvent() async {
    final provider = Provider.of<EventsProvider>(context, listen: false);

    String eventName = _eventNameController.text.trim();
    String location = _eventLocationController.text.trim();
    String eventDescription = _eventDescController.text.trim();
    String startTimeString = _startTimeController.text.trim();
    String endTimeString = _endTimeController.text.trim();

    // Convert String to TimeOfDay
    final startTime = _stringToTimeOfDay(startTimeString);
    final endTime = _stringToTimeOfDay(endTimeString);

    if (eventName.isEmpty ||
        eventDescription.isEmpty ||
        location.isEmpty ||
        _scheduledDate == null ||
        startTimeString.isEmpty ||
        endTimeString.isEmpty ||
        _selectedEventType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
          'Please fill in all fields!',
          style: GoogleFonts.openSans(fontSize: 14),
        )),
      );
      return;
    }

    if (!_isValidTimeRange(startTime!, endTime!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
          'Start Time must be before End Time.',
          style: GoogleFonts.openSans(fontSize: 14),
        )),
      );
      return;
    }

    try {
      await provider.addEvent(
        eventName: eventName,
        eventDesc: eventDescription,
        location: location,
        scheduledDate: _scheduledDate!,
        startTime: startTime,
        endTime: endTime,
        eventType: _selectedEventType!,
      );

      // Success Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        _buildSnackBar(
          icon: Icons.check_circle,
          text: 'Event created successfully!',
          backgroundColor: Color(0xFF50B6FF).withOpacity(0.8),
        ),
      );

      Navigator.pop(context);
      _clearFields();
    } catch (error) {
      String errorMessage = 'Failed to create event';

      if (error.toString().contains('Scheduling overlap')) {
        errorMessage =
            'Scheduling overlap: This time slot is already occupied.';
      } else if (error.toString().contains('Duplicate event entry detected')) {
        errorMessage = 'Duplicate event entry: This event already exists.';
      } else {
        errorMessage = 'Failed to create event: $error';
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
                    _buildTitle(
                      'Event Name',
                    ),
                    const SizedBox(height: 12),
                    CustomWidgets.buildTextField(
                        _eventNameController, 'Event Name'),
                    const SizedBox(height: 12),
                    _buildTitle(
                      'Description',
                    ),
                    const SizedBox(height: 12),
                    CustomWidgets.buildTextField(
                        _eventDescController, 'Description'),
                    const SizedBox(height: 12),
                    _buildTitle(
                      'Location',
                    ),
                    const SizedBox(height: 12),
                    CustomWidgets.buildTextField(
                        _eventLocationController, 'Location'),
                    const SizedBox(height: 12),
                    _buildTitle(
                      'Scheduled Date',
                    ),
                    const SizedBox(height: 12),
                    CustomWidgets.buildDateTile('Scheduled Date',
                        _scheduledDate, context, true, _selectDate),
                    const SizedBox(height: 12),
                    _buildTitle(
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
                            (context) =>
                                _selectTime(context, _endTimeController),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildTitle(
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
