import 'package:flutter/material.dart';
import 'package:planma_app/task/view_task.dart';
import 'package:planma_app/task/widget/task_card.dart';
import 'package:planma_app/task/widget/task_section.dart';

class BySubjectView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        TaskSection(
          title: 'Subject Code 1',
          tasks: [
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewTask(
                      taskName: 'Task Name 1',
                      description: 'Description for Task 1',
                      date: '11 January 2024',
                      time: '00:00 AM - 00:00 AM',
                      deadline: '14 January 2024',
                      subject: 'Subject Code 1',
                    ),
                  ),
                );
              },
              child: TaskCard(
                taskName: 'Task Name 1',
                subject: 'Subject Code 1',
                duration: 'Duration',
              ),
            ),
          ],
        ),
        TaskSection(
          title: 'Subject Code 2',
          tasks: [
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewTask(
                      taskName: 'Task Name 2',
                      description: 'Description for Task 2',
                      date: '12 January 2024',
                      time: '10:00 AM - 12:00 PM',
                      deadline: '15 January 2024',
                      subject: 'Subject Code 2',
                    ),
                  ),
                );
              },
              child: TaskCard(
                taskName: 'Task Name 2',
                subject: 'Subject Code 2',
                duration: 'Duration',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

