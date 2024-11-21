import 'package:flutter/material.dart';
import 'package:planma_app/timer/countdown/countdown_timer.dart'; // Import TimerPage

class TaskCard extends StatefulWidget {
  final String taskName;
  final String subject;
  final String duration;

  const TaskCard({
    super.key,
    required this.taskName,
    required this.subject,
    required this.duration,
  });

  @override
  _TaskCardState createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: 10, top: 5, bottom: 5), // Left margin for the whole card
      child: InkWell(
        onTap: () {
          // Navigate to TimerPage
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TimerPage()),
          );
        },
        borderRadius:
            BorderRadius.circular(10), // Match container border radius
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.blue[100],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.access_time, // Time icon
                    size: 24,
                    color: Colors.blue, // Icon color
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.taskName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('${widget.subject} (${widget.duration})'),
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
