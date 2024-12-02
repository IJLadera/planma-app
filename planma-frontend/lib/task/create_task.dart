import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:planma_app/task/widget/widgets.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  _CreateTaskState createState() => _CreateTaskState();
}

class _CreateTaskState extends State<AddTaskScreen> {
  final TextEditingController _taskNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();

  DateTime? _scheduledDate;
  DateTime? _deadline;
  String? _subject;

  final List<String> _subjectsOptions = ['Math', 'Science', 'English'];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Task',
          style: GoogleFonts.openSans(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Color(0xFF173F70)),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
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
                    'Task Name',
                  ),
                  const SizedBox(height: 12),
                  CustomWidgets.buildTextField(
                    _taskNameController,
                    'Task Name',
                  ),
                  const SizedBox(height: 12),
                  _buildTitle('Description'),
                  const SizedBox(height: 12),
                  CustomWidgets.buildTextField(
                    _descriptionController,
                    'Description',
                  ),
                  const SizedBox(height: 12),
                  _buildTitle('Schedule Date'),
                  const SizedBox(height: 12),
                  CustomWidgets.buildDateTile(
                    'Scheduled Date',
                    _scheduledDate,
                    context,
                    true,
                    _selectDate,
                  ),
                  const SizedBox(height: 12),
                  _buildTitle('Start and End Time'),
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
                  _buildTitle('Deadline'),
                  const SizedBox(height: 12),
                  CustomWidgets.buildDateTile(
                    'Deadline',
                    _deadline,
                    context,
                    false,
                    _selectDate,
                  ),
                  const SizedBox(height: 12),
                  _buildTitle('Choose a Subject'),
                  const SizedBox(height: 12),
                  CustomWidgets.buildDropdownField(
                    label: 'Choose Subject',
                    value: _subject,
                    items: _subjectsOptions,
                    onChanged: (String? value) {
                      setState(() {
                        _subject = value;
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
              onPressed: () {
                // Action to create the task
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF173F70),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 120),
              ),
              child: Text(
                'Create Task',
                style: GoogleFonts.openSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
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
