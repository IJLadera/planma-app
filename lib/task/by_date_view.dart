import 'package:flutter/material.dart';
import 'package:planma_app/task/widget/task_card.dart';
import 'package:planma_app/task/widget/task_section.dart';

class ByDateView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        TaskSection(
          title: 'Today',
          tasks: [
            TaskCard(
              taskName: 'Task Name 1',
              subject: 'Subject',
              duration: 'Duration',
              icon: Icons.flag,
              priority: 'High',
            ),
            TaskCard(
              taskName: 'Task Name 2',
              subject: 'Subject',
              duration: 'Duration',
              icon: Icons.flag,
              priority: 'High',
            ),
            TaskCard(
              taskName: 'Task Name 3',
              subject: 'Subject',
              duration: 'Duration',
              icon: Icons.flag,
              priority: 'High',
            ),
          ],
        ),
        TaskSection(
          title: 'Tomorrow',
          tasks: [
            TaskCard(
              taskName: 'Task Name 4',
              subject: 'Subject',
              duration: 'Duration',
              icon: Icons.flag,
              priority: 'High',
            ),
          ],
        ),
      ],
    );
  }
}
