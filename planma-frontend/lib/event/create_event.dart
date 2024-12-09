import 'package:flutter/material.dart';
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
      
      // After validation and adding logic
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('event added successfully!')),
      ); 

      Navigator.pop(context);
      // Clear fields after adding
      _clearFields();     
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add event (1): $error')),
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
      body: Column(
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
                    'Schedule Date',
                  ),
                  const SizedBox(height: 12),
                  CustomWidgets.buildDateTile('Scheduled Date', _scheduledDate,
                      context, true, _selectDate),
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
                          (context) => _selectTime(context, _endTimeController),
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
                    labelColor: Colors.black,
                    textColor: Colors.black,
                    borderRadius: 30.0,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
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
                  borderRadius: BorderRadius.circular(10),
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
