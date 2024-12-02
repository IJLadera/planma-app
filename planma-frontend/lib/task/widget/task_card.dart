import 'package:flutter/material.dart';
import 'package:planma_app/timer/countdown/countdown_timer.dart'; // Import TimerPage
import 'package:planma_app/task/view_task.dart'; // Import ViewTask
import 'package:google_fonts/google_fonts.dart';

class TaskCard extends StatefulWidget {
  final String taskName;
  final String subject;
  final String duration;
  final String description;
  final String date;
  final String time;
  final String deadline;

  const TaskCard({
    super.key,
    required this.taskName,
    required this.subject,
    required this.duration,
    required this.description,
    required this.date,
    required this.time,
    required this.deadline,
  });

  @override
  _TaskCardState createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: 8, horizontal: 16), // Add padding around the whole list
      child: InkWell(
        onTap: () {
          // Navigate to ViewTask with dynamic data
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ViewTask(
                taskName: widget.taskName,
                description: widget.description,
                date: widget.date,
                time: widget.time,
                deadline: widget.deadline,
                subject: widget.subject,
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
                        widget.taskName,
                        style: GoogleFonts.openSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF173F70),
                        ),
                      ),
                      Text(
                        '${widget.subject} (${widget.duration})',
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
