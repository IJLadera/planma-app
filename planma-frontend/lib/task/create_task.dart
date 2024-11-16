import 'package:flutter/material.dart';
import 'package:planma_app/task/widget/widgets.dart';
 // Import your CustomWidgets class

class CreateTask extends StatefulWidget {
  const CreateTask({super.key});

  @override
  _CreateTaskState createState() => _CreateTaskState();
}

class _CreateTaskState extends State<CreateTask> {
  final TextEditingController _taskNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

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
  Future<void> _selectDate(BuildContext context, bool isScheduledDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isScheduledDate) {
          _scheduledDate = picked;
        } else {
          _deadline = picked;
        }
      });
    }
  }

  // Method to select time
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
                  const SizedBox(height: 12), // Added gap
                  Row(
                    children: [
                      Expanded(
                          child: CustomWidgets.buildTimeField('Start Time',
                              _startTime, context, true, _selectTime)),
                      const SizedBox(width: 10),
                      Expanded(
                          child: CustomWidgets.buildTimeField('End Time',
                              _endTime, context, false, _selectTime)),
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
                backgroundColor: Colors.blue.shade700,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 120),
              ),
              child: const Text(
                'Create Task',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
