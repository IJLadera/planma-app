import 'package:flutter/material.dart';
import 'package:planma_app/event/widget/widget.dart';

class AddEventState extends StatefulWidget {
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
