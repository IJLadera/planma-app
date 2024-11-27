import 'package:flutter/material.dart';
import 'package:planma_app/timer/countdown/countdown_timer.dart'; // Import TimerPage
import 'package:planma_app/task/view_task.dart'; // Import ViewTask

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
      padding: const EdgeInsets.fromLTRB(15, 8, 15, 8),
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
            color: Colors.blue[100],
            borderRadius:
                BorderRadius.circular(12), // Matching radius for consistency
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // Separate InkWell for the time icon
                  InkWell(
                    onTap: () {
                      // Navigate to TimerPage when the time icon is tapped
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => TimerPage()),
                      );
                    },
                    borderRadius:
                        BorderRadius.circular(50), // Circular for icon
                    child: const Padding(
                      padding: EdgeInsets.all(
                          12.0), // Increased padding around the icon
                      child: Icon(
                        Icons.access_time, // Time icon
                        size: 28, // Slightly larger icon size
                        color: Colors.blue, // Icon color
                      ),
                    ),
                  ),
                  const SizedBox(
                      width: 12), // Increased space between icon and text
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 8.0), // Padding around text
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.taskName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16, // Larger font size for task name
                          ),
                        ),
                        Text(
                          '${widget.subject} (${widget.duration})',
                          style: const TextStyle(
                            fontSize:
                                14, // Smaller font size for subject/duration
                          ),
                        ),
                      ],
                    ),
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
