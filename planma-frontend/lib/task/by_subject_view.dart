import 'package:flutter/material.dart';
import 'package:planma_app/models/tasks_model.dart';
import 'package:planma_app/task/widget/task_card.dart';
import 'package:planma_app/task/widget/task_section.dart';

class BySubjectView extends StatelessWidget {
  final List<Task> tasksView;

  const BySubjectView({
    super.key, 
    required this.tasksView
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: tasksView.length,
      itemBuilder: (context, index) {
        final task = tasksView[index];
        return SizedBox(
          // height: 120,
          child: TaskCard(
            isByDate: false, 
            task: task
          ),
        );
      },
      // children: tasksView.entries.map((entry) {
      //   return TaskSection(
      //     title: entry.key,
      //     tasks: entry.value.map((task) {
      //       return TaskCard(
      //         taskName: task['taskName'],
      //         subject: task['subject'],
      //         duration: task['duration'],
      //         description: task['description'],
      //         date: task['date'],
      //         time: task['time'],
      //         deadline: task['deadline'],
      //       );
      //     }).toList(),
      //   );
      // }).toList(),
    );
  }
}
