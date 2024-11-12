import 'package:flutter/material.dart';
import 'package:planma_app/task/widget/task_item.dart';

class TaskSection extends StatelessWidget {
  final String title;
  final List<TaskItem> tasks;

  TaskSection({required this.title, required this.tasks});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Column(children: tasks),
      ],
    );
  }
}
