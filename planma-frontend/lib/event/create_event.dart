import 'package:flutter/material.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:planma_app/Providers/user_provider.dart';
import 'package:planma_app/authentication/log_in.dart';
import 'package:planma_app/event/widget/widget.dart';
import 'package:planma_app/Front%20&%20back%20end%20connections/events_service.dart';
import 'package:provider/provider.dart';

class AddEventState extends StatefulWidget {
  const AddEventState({super.key});

  @override
  _AddEventState createState() => _AddEventState();
}

class _AddEventState extends State<AddEventState> {
  final _eventCodeController = TextEditingController();
  final _eventTitleController = TextEditingController();
  final _eventLocationController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();

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

  String to24HourFormat(String time) {
  String finalStrTime = "";
  List<String> timeSplit = time.split(":");
  timeSplit[1] = timeSplit[1].split(" ").first;
  if (time.split(" ")[1] == "PM") {
    if (time.split(":").first == "12") {
      // dont adjust by 12 hours if 12 PM
      finalStrTime = "${timeSplit[0]}:${timeSplit[1]}";
    } else {
      finalStrTime = "${(int.parse(timeSplit[0]) + 12).toString()}:${timeSplit[1]}";
    }
  } else if (time.split(" ")[1] == "AM" && time.split(":").first == "12") {
    // if 12 AM, adjust by - 12
    finalStrTime = "${(int.parse(timeSplit[0]) - 12).toString()}:${timeSplit[1]}";
  } else {
    // if <12 PM just return hh:mm
    finalStrTime = "${timeSplit[0]}:${timeSplit[1]}";
  }
  return finalStrTime;
}

  Future<void> _createEvent() async {
    if (_eventCodeController.text.isEmpty ||
        _eventTitleController.text.isEmpty ||
        _eventLocationController.text.isEmpty ||
        _scheduledDate == null ||
        _startTimeController.text.isEmpty ||
        _endTimeController.text.isEmpty ||
        _selectedEventType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill out all fields')),
      );
      return;
    }
    final eventService = EventsCreate();
    // Collect data from UI inputs
    final String eventName = _eventCodeController.text;
    final String eventDesc = _eventTitleController.text;
    final String location = _eventLocationController.text;
    final String scheduledDate = _scheduledDate!.toIso8601String().split("T").first;
    final String startTime = _startTimeController.text;
    final String endTime = _endTimeController.text;
    final String eventType = _selectedEventType!;
    
    
    

    // Call the service

    final result = await eventService.eventCT(
      eventname: eventName,
      eventdesc: eventDesc,
      location: location,
      scheduledate: scheduledDate,
      starttime: to24HourFormat(startTime),
      endtime: to24HourFormat(endTime),
      eventtype: eventType,
      studentID: Jwt.parseJwt(context.read<UserProvider>().accessToken!)['user_id']
    );

    // Handle response
    if (result != null && result.containsKey('error')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['error'])),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Event created successfully!')),
      );
      Navigator.of(context).pop(); // Navigate back on success
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Add Event'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: Column(
          children: [
            Expanded(
                child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  CustomWidgets.buildTextField(
                      _eventCodeController, 'Event Name'),
                  SizedBox(height: 16), // Increased space
                  CustomWidgets.buildTextField(
                      _eventTitleController, 'Description'),
                  SizedBox(
                      height: 16), // Space between time fields and room field
                  CustomWidgets.buildTextField(
                      _eventLocationController, 'Location'),
                  const SizedBox(height: 12),
                  CustomWidgets.buildDateTile('Scheduled Date', _scheduledDate,
                      context, true, _selectDate),
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
                  SizedBox(height: 12), SizedBox(height: 16), // Increased space
                  CustomWidgets.buildDropdownField(
                      'Event Type', _selectedEventType, _EventType, (value) {
                    setState(() {
                      _selectedEventType = value;
                    });
                  }),
                ],
              ),
            )),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              child: ElevatedButton(
                onPressed: _createEvent, 
                  // Create task action
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 120),
                ),
                child: Text(
                  'Create Event',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ));
  }
}
