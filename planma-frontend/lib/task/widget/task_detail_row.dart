import 'package:flutter/material.dart';

class TaskDetailRow extends StatelessWidget {
  final String title;
  final String detail;

  const TaskDetailRow({
    super.key,
    required this.title,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              title,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF173F70),
                  fontSize: 16),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              detail,
              style: const TextStyle(color: Color(0xFF173F70), fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
