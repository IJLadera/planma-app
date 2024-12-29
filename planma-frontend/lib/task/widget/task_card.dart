import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:planma_app/models/tasks_model.dart';
import 'package:planma_app/timer/countdown/countdown_timer.dart'; // Import TimerPage
import 'package:planma_app/task/view_task.dart'; // Import ViewTask
import 'package:google_fonts/google_fonts.dart';

class TaskCard extends StatelessWidget {
  final bool isByDate;
  final Task task;

  const TaskCard({
    super.key,
    required this.isByDate,
    required this.task,
  });

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

  @override
  Widget build(BuildContext context) {
    final startTime = _formatTimeForDisplay(task.scheduledStartTime);
    final endTime = _formatTimeForDisplay(task.scheduledEndTime);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0), // Rounded corners
        ),
        elevation: 5, // Adds shadow effect for better UX
        child: InkWell(
          borderRadius: BorderRadius.circular(12.0),
          onTap: () {
            // Navigate to ViewTask with dynamic data
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TaskDetailScreen(task: task),
              ),
            );
          },
          child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color:
                    Color(0xFFC0D7F3).withOpacity(0.6), // Slight transparency
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  // GestureDetector for the time icon (same as original position)
                  GestureDetector(
                    onTap: () {
                      // Navigate to TimerPage when the time icon is tapped
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              TimerPage(themeColor: Colors.blueAccent),
                        ),
                      );
                    },
                    child: const Icon(
                      Icons.play_circle_fill, // Time icon
                      size: 28, // Slightly larger icon size
                      color: Color(0xFF173F70), // Icon color
                    ),
                  ),
                  const SizedBox(width: 12), // Space between icon and divider
                  Container(
                    height: 50, // The height of the divider, adjust as needed
                    width: 2, // The thickness of the divider
                    color: Color(0xFF0095FF), // Divider color
                  ),
                  const SizedBox(width: 12), // Space between divider and text
                  Expanded(
                    // Ensure the text takes up remaining space
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Task Name
                        Text(
                          task.taskName,
                          style: GoogleFonts.openSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF173F70),
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Subject Code with time range
                        Text(
                          '${task.subject?.subjectCode} ($startTime - $endTime)',
                          style: GoogleFonts.openSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF173F70),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )),
        ),
      ),
    );
  }
}
