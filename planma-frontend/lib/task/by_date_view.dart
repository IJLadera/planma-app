import 'package:flutter/material.dart';
import 'package:planma_app/models/tasks_model.dart';
import 'package:planma_app/task/widget/task_card.dart';
import 'package:google_fonts/google_fonts.dart';

class ByDateView extends StatelessWidget {
  final List<Task> tasksView;

  const ByDateView({super.key, required this.tasksView});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Categorize tasks
    final Map<String, List<Task>> groupedTasks = {
      "Past": tasksView
          .where((task) => task.scheduledDate.isBefore(today))
          .toList(),
      "Today": tasksView
          .where((task) => task.scheduledDate.isAtSameMomentAs(today))
          .toList(),
      "Tomorrow": tasksView
          .where((task) => task.scheduledDate
              .isAtSameMomentAs(today.add(const Duration(days: 1))))
          .toList(),
      "This Week": tasksView.where((task) {
        final weekEnd = today.add(Duration(days: 7 - today.weekday));
        return task.scheduledDate.isAfter(today) &&
            task.scheduledDate.isBefore(weekEnd) &&
            !task.scheduledDate
                .isAtSameMomentAs(today.add(const Duration(days: 1)));
      }).toList(),
      "Future": tasksView
          .where((task) => task.scheduledDate
              .isAfter(today.add(Duration(days: 7 - today.weekday))))
          .toList(),
    };

    return ListView(
      children: groupedTasks.entries.map((entry) {
        final category = entry.key;
        final tasks = entry.value;

        return tasks.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 16.0, right: 16.0, bottom: 8.0),
                      child: Text(
                        category,
                        style: GoogleFonts.openSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: tasks.length,
                      itemBuilder: (context, idx) {
                        final task = tasks[idx];
                        return SizedBox(
                          // height: 120,
                          child: TaskCard(isByDate: true, task: task),
                        );
                      },
                    ),
                  ],
                ),
              )
            : Container();
      }).toList(),
    );
  }
}
