import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:planma_app/task/edit_task.dart';
import 'package:planma_app/task/widget/task_detail_row.dart';

class ViewTask extends StatelessWidget {
  final String taskName;
  final String description;
  final String date;
  final String time;
  final String deadline;
  final String subject;

  const ViewTask({
    super.key,
    required this.taskName,
    required this.description,
    required this.date,
    required this.time,
    required this.deadline,
    required this.subject,
  });

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Closes the view after deletion
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF173F70)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFF173F70)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EditTask()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _confirmDelete(context),
          ),
        ],
        centerTitle: true,
        title: Text(
          'Task',
          style: GoogleFonts.openSans(
            color: Color(0xFF173F70),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[100],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TaskDetailRow(title: 'Name:', detail: taskName),
                const SizedBox(height: 8),
                TaskDetailRow(title: 'Description:', detail: description),
                const SizedBox(height: 8),
                TaskDetailRow(title: 'Date:', detail: date),
                const SizedBox(height: 8),
                TaskDetailRow(title: 'Time:', detail: time),
                const SizedBox(height: 8),
                TaskDetailRow(title: 'Deadline:', detail: deadline),
                const SizedBox(height: 8),
                TaskDetailRow(title: 'Subject:', detail: subject),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
