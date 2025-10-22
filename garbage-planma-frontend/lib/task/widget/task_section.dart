import 'package:flutter/material.dart';

class TaskSection extends StatelessWidget {
  final String title;
  final List<Widget> tasks;

  const TaskSection({super.key, required this.title, required this.tasks});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF173F70)),
          ),
          ...tasks,
        ],
      ),
    );
  }
}
