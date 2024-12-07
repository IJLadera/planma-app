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
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16), // Add padding around the whole list
      child: InkWell(
        onTap: () {
          // Navigate to ViewTask with dynamic data
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TaskDetailScreen(
                task: task
              ),
            ),
          );
        },
        borderRadius:
            BorderRadius.circular(12), // Slightly larger border radius
        child: Container(
          padding:
              const EdgeInsets.all(16), // Increased padding inside the card
          decoration: BoxDecoration(
            color: Color(0xFFC0D7F3),
            borderRadius:
                BorderRadius.circular(12), // Matching radius for consistency
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // Separate GestureDetector for the time icon
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
                      Icons.access_time, // Time icon
                      size: 28, // Slightly larger icon size
                      color: Color(0xFF173F70), // Icon color
                    ),
                  ),
                  const SizedBox(
                      width: 12), // Increased space between icon and text
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.taskName,
                        style: GoogleFonts.openSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF173F70),
                        ),
                      ),
                      Text(
                        '${task.subjectCode} ($startTime - $endTime)',
                        style: GoogleFonts.openSans(
                          fontSize: 14,
                          color: Color(0xFF173F70),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}