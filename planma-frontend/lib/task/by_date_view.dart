import 'package:flutter/material.dart';
import 'package:planma_app/task/widget/task_card.dart';
import 'package:planma_app/task/widget/task_section.dart';
import 'package:planma_app/task/view_task.dart'; // Updated import to match the ViewTask class

class ByDateView extends StatelessWidget {
  const ByDateView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        TaskSection(
          title: 'Today',
          tasks: [
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ViewTask(
                      taskName: 'Task Name 1',
                      description: 'Description for Task 1',
                      date: 'Today',
                      time: '10:00 AM - 12:00 PM',
                      deadline: 'Today',
                      subject: 'Subject Code 1',
                    ),
                  ),
                );
              },
              child: TaskCard(
                taskName: 'Task Name 1',
                subject: 'Subject Code 1',
                duration: '2 hrs',
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ViewTask(
                      taskName: 'Task Name 2',
                      description: 'Description for Task 2',
                      date: 'Today',
                      time: '1:00 PM - 3:00 PM',
                      deadline: 'Today',
                      subject: 'Subject Code 2',
                    ),
                  ),
                );
              },
              child: TaskCard(
                taskName: 'Task Name 2',
                subject: 'Subject Code 2',
                duration: '2 hrs',
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ViewTask(
                      taskName: 'Task Name 3',
                      description: 'Description for Task 3',
                      date: 'Today',
                      time: '3:30 PM - 5:30 PM',
                      deadline: 'Today',
                      subject: 'Subject Code 3',
                    ),
                  ),
                );
              },
              child: TaskCard(
                taskName: 'Task Name 3',
                subject: 'Subject Code 3',
                duration: '2 hrs',
              ),
            ),
          ],
        ),
      ],
    );
  }
}
