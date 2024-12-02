import 'package:flutter/material.dart';
import 'package:planma_app/event/widget/widget.dart';
import 'package:google_fonts/google_fonts.dart';

class EditEvent extends StatefulWidget {
  const EditEvent({super.key});

  @override
  _EditEvent createState() => _EditEvent();
}

class _EditEvent extends State<EditEvent> {
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
                  _buildTitle(
                    'Event Name',
                  ),
                  const SizedBox(height: 12),
                  CustomWidgets.buildTextField(
                      _eventCodeController, 'Event Name'),
                  SizedBox(height: 12),
                  _buildTitle(
                    'Description',
                  ),
                  const SizedBox(height: 12), // Increased space
                  CustomWidgets.buildTextField(
                      _eventTitleController, 'Description'),
                  SizedBox(height: 12),
                  _buildTitle(
                    'Location',
                  ),
                  const SizedBox(height: 12),
                  CustomWidgets.buildTextField(
                      _eventLocationController, 'Location'),
                  SizedBox(height: 12),
                  _buildTitle(
                    'Scheduled Date',
                  ),
                  const SizedBox(height: 12),
                  CustomWidgets.buildDateTile('Scheduled Date', _scheduledDate,
                      context, true, _selectDate),
                  SizedBox(height: 12),
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
                  SizedBox(height: 12),
                  _buildTitle(
                    'Choose Subject',
                  ),
                  const SizedBox(height: 12),
                  CustomWidgets.buildDropdownField(
                    label:
                        'Choose Subject', // Updated the label for consistency
                    value: _selectedEventType,
                    items: _EventType,
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
                  )
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
                  backgroundColor: Color(0xFF173F70),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
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
