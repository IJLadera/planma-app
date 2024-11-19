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
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
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
              GestureDetector(
                onTap: () {
                  // Navigate to TimerPage
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TimerPage()),
                  );
                },
                child: const Icon(
                  Icons.access_time, // Time icon
                  size: 24,
                  color: Colors.blue, // Icon color
                ),
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
    );
  }
}
