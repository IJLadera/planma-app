import 'package:flutter/material.dart';
import 'package:planma_app/task/widget/widgets.dart';
import 'package:intl/intl.dart'; // For date formatting

class EditTask extends StatefulWidget {
  const EditTask({super.key});

  @override
  _EditTask createState() => _EditTask();
}

class _EditTask extends State<EditTask> {
  final TextEditingController _taskNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();

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
        title: const Text(
          'Edit Task',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
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
                    _taskNameController,
                    'Task Name',
                  ),
                  const SizedBox(height: 12),
                  CustomWidgets.buildTextField(
                    _descriptionController,
                    'Description',
                  ),
                  const SizedBox(height: 12),
                  CustomWidgets.buildDateTile(
                    'Scheduled Date',
                    _scheduledDate,
                    context,
                    true, // Indicates it's the start date
                    _selectDate, // Pass the selectDate function reference
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
                  CustomWidgets.buildDateTile(
                    'Deadline',
                    _deadline,
                    context,
                    false, // Indicates it's the deadline date
                    _selectDate, // Pass the selectDate function reference
                  ),
                  const SizedBox(height: 12),
                  CustomWidgets.buildDropdownField(
                    label:
                        'Choose Subject', // Updated the label for consistency
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
                  )
                ],
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: ElevatedButton(
              onPressed: () {
                // Create task action
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF173F70),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 120),
              ),
              child: const Text(
                'Edit Task',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
