import 'package:flutter/material.dart';

class TaskDetailRow extends StatelessWidget {
  final String title;
  final String detail;

  const TaskDetailRow({
    Key? key,
    required this.title,
    required this.detail,
  }) : super(key: key);

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
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[800]),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              detail,
              style: const TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
