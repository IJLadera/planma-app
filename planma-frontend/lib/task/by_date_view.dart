import 'package:flutter/material.dart';
import 'package:planma_app/models/tasks_model.dart';
import 'package:planma_app/task/widget/task_card.dart';

class ByDateView extends StatelessWidget {
  final List<Task> tasksView;

  const ByDateView({super.key, required this.tasksView});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: tasksView.length,
      itemBuilder: (context, index) {
        final task = tasksView[index];
        return SizedBox(
          // height: 120,
          child: TaskCard(isByDate: true, task: task),
        );
      },
    );
  }
}
