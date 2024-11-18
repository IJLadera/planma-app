import 'package:flutter/material.dart';
import 'package:planma_app/subject/widget/widget.dart';

class AddEventState extends StatefulWidget {
  @override
  _AddEventState createState() => _AddEventState();
}

class _AddEventState extends State<AddEventState> {
  final _eventCodeController = TextEditingController();
  final _eventTitleController = TextEditingController();
  final _eventLocationController = TextEditingController();

  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  DateTime? _date;
  String? _selectedEventType;
  final List<String> _semesters = ['Academic', 'Personal'];

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _selectDate(BuildContext context, DateTime? selectedDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _date = picked;
        print("Selected date: $_date");
      });
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
                  SizedBox(height: 20), // Added more gap below the last field

                  SizedBox(height: 12),
                  CustomWidgets.buildDateTile(
                    'Date', _date, context, _selectDate, // No `isScheduledDate`
                  ),
                  SizedBox(height: 12), // Added gap
                  Row(
                    children: [
                      Expanded(
                          child: CustomWidgets.buildTimeField('Start Time',
                              _startTime, context, true, _selectTime)),
                      SizedBox(width: 10),
                      Expanded(
                          child: CustomWidgets.buildTimeField('End Time',
                              _endTime, context, false, _selectTime)),
                    ],
                  ),
                  SizedBox(height: 12), SizedBox(height: 16), // Increased space
                  CustomWidgets.buildDropdownField(
                      'Event Type', _selectedEventType, _semesters, (value) {
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
                onPressed: () {
                  // Create task action
                },
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
