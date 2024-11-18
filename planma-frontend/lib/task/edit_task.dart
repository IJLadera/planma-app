import 'package:flutter/material.dart';
import 'package:planma_app/task/widget/widgets.dart';
// Import your CustomWidgets class

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
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  DateTime? _deadline;

  String? _subject;

  final List<String> _subjects = [
    'Math',
    'Science',
    'English'
  ]; // Add your subjects here

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
          'Add Task',
          style: TextStyle(
            fontWeight: FontWeight.bold, // Makes the text bold
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
                      _taskNameController, 'Task Name'),
                  const SizedBox(height: 12), // Added gap
                  CustomWidgets.buildTextField(
                      _descriptionController, 'Description'),
                  const SizedBox(height: 12), // Added gap
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
                  const SizedBox(height: 12),
                  CustomWidgets.buildDateTile(
                      'Deadline', _deadline, context, false, _selectDate),
                  const SizedBox(height: 12), // Added gap
                  CustomWidgets.buildDropdownField(
                      'Subject', _subject, _subjects, (value) {
                    setState(() {
                      _subject = value;
                    });
                  }),
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
                backgroundColor: Color(0xFF173F70),
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
