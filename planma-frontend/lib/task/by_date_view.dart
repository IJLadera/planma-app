import 'package:flutter/material.dart';
import 'package:planma_app/task/widget/task_card.dart';

class ByDateView extends StatelessWidget {
  final List<Map<String, dynamic>> tasks;

  const ByDateView({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return TaskCard(
          taskName: task['taskName'],
          subject: task['subject'],
          duration: task['duration'],
          description: task['description'],
          date: task['date'],
          time: task['time'],
          deadline: task['deadline'],
        );
      },
    );
  }
}
