import 'package:flutter/material.dart';
import 'package:planma_app/goals/widget/widget.dart'; // Ensure this file contains the CustomWidgets class

class AddGoalScreen extends StatefulWidget {
  @override
  _AddGoalScreenState createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends State<AddGoalScreen> {
  final _goalCodeController = TextEditingController();

  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  DateTime? _goalDate;

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

  Future<void> _selectDate(BuildContext context, bool isScheduledDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _goalDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Goal Sessions'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
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
                  const SizedBox(height: 16),
                  CustomWidgets.buildTextField(
                    _goalCodeController,
                    'Goal Name',
                  ),
                  const SizedBox(height: 16),
                  // Clickable Date Picker
                  CustomWidgets.buildDateTile(
                    'Scheduled Date',
                    _goalDate,
                    context,
                    true,
                    _selectDate,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: CustomWidgets.buildTimeField(
                          'Start Time',
                          _startTime,
                          context,
                          true,
                          _selectTime,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomWidgets.buildTimeField(
                          'End Time',
                          _endTime,
                          context,
                          false,
                          _selectTime,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 20.0,
            ),
            child: ElevatedButton(
              onPressed: () {
                // TODO: Add functionality to save the goal session
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 120,
                ),
              ),
              child: const Text(
                'Create Goal Session',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
