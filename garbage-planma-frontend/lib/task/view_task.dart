import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:planma_app/Providers/task_provider.dart';
import 'package:planma_app/models/tasks_model.dart';
import 'package:planma_app/task/edit_task.dart';
import 'package:planma_app/task/widget/task_detail_row.dart';
import 'package:provider/provider.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task task;

  TaskDetailScreen({
    super.key,
    required this.task,
  });

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late TaskProvider taskProvider;

  void _handleDelete(BuildContext context) async {
    final provider = Provider.of<TaskProvider>(context, listen: false);
    final isConfirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Task',
          style: GoogleFonts.openSans(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
        ),
        content: Text('Are you sure you want to delete this task?',
            style:
                GoogleFonts.openSans(fontSize: 16, color: Color(0xFF1D4E89))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel',
                style: GoogleFonts.openSans(
                    fontSize: 16, color: Color(0xFF1D4E89))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(
              'Delete',
              style:
                  GoogleFonts.openSans(fontSize: 16, color: Color(0xFF1D4E89)),
            ),
          ),
        ],
      ),
    );

    if (isConfirmed == true) {
      provider.deleteTask(widget.task.taskId!);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 24),
            const SizedBox(width: 8),
            Text(
              'Deleted Task successfully',
              style: GoogleFonts.openSans(fontSize: 16, color: Colors.white),
            )
          ],
        ),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height * 0.4,
          left: 50,
          right: 50,
          top: 100,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Color(0xFF50B6FF).withOpacity(0.8),
        elevation: 10,
      ));
    }
  }

  String _formatTimeForDisplay(String time24) {
    final timeParts = time24.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    final timeOfDay = TimeOfDay(hour: hour, minute: minute);

    // Format to "H:mm a"
    final now = DateTime.now();
    final dateTime = DateTime(
      now.year,
      now.month,
      now.day,
      timeOfDay.hour,
      timeOfDay.minute,
    );
    return DateFormat.jm().format(dateTime);
  }

  String _formatScheduledDate(DateTime date) {
    return DateFormat('dd MMMM yyyy').format(date); // Example: 09 December 2024
  }

  String _formatDeadline(DateTime date) {
    return DateFormat('dd MMMM yyyy - hh:mm a')
        .format(date); // Example: 18 December 2024 - 12:00 AM
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(builder: (context, taskProvider, child) {
      final task = taskProvider.tasks.firstWhere(
        (task) => task.taskId == widget.task.taskId,
        orElse: () => Task(
          taskId: -1,
          taskName: 'N/A',
          taskDescription: 'N/A',
          scheduledDate: DateTime(2020, 1, 1),
          scheduledStartTime: '00:00',
          scheduledEndTime: '00:00',
          deadline: DateTime(2020, 1, 1, 0, 0),
          subject: null,
        ),
      );

      if (task.taskId == -1) {
        return Scaffold(
          appBar: AppBar(title: Text('Task Details')),
          body: Center(child: Text('Task not found')),
        );
      }

      final startTime = _formatTimeForDisplay(task.scheduledStartTime);
      final endTime = _formatTimeForDisplay(task.scheduledEndTime);
      final formattedScheduledDate = _formatScheduledDate(task.scheduledDate);
      final formattedDeadline = _formatDeadline(task.deadline);

      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFF173F70)),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditTask(task: task)),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Color(0xFF173F70)),
              onPressed: () => _handleDelete(context),
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
                  TaskDetailRow(title: 'Name:', detail: task.taskName),
                  const Divider(),
                  TaskDetailRow(
                      title: 'Description:', detail: task.taskDescription),
                  const Divider(),
                  TaskDetailRow(title: 'Date:', detail: formattedScheduledDate),
                  const Divider(),
                  TaskDetailRow(
                      title: 'Time:', detail: '$startTime - $endTime'),
                  const Divider(),
                  TaskDetailRow(title: 'Deadline:', detail: formattedDeadline),
                  const Divider(),
                  TaskDetailRow(
                      title: 'Subject:', detail: task.subject?.subjectTitle),
                  const Divider(),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
