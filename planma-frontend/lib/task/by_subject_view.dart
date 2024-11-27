import 'package:flutter/material.dart';
import 'package:planma_app/task/widget/task_card.dart';
import 'package:planma_app/task/widget/task_section.dart';

class BySubjectView extends StatelessWidget {
  final Map<String, List<Map<String, dynamic>>> tasksBySubject;

  const BySubjectView({super.key, required this.tasksBySubject});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: tasksBySubject.entries.map((entry) {
        return TaskSection(
          title: entry.key,
          tasks: entry.value.map((task) {
            return TaskCard(
              taskName: task['taskName'],
              subject: task['subject'],
              duration: task['duration'],
              description: task['description'],
              date: task['date'],
              time: task['time'],
              deadline: task['deadline'],
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}
