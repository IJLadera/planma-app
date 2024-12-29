import 'package:flutter/material.dart';
import 'package:planma_app/models/tasks_model.dart';
import 'package:planma_app/task/widget/task_card.dart';
import 'package:google_fonts/google_fonts.dart';

class BySubjectView extends StatelessWidget {
  final List<Task> tasksView;

  const BySubjectView({
    super.key, 
    required this.tasksView
  });

  @override
  Widget build(BuildContext context) {
    final List<String?> subjects = tasksView
        .map((task) => task.subject?.subjectCode)
        .toSet() // Use a Set to remove duplicates
        .toList();

    print("Subjects List: $subjects");

    return ListView.builder(
      itemCount: subjects.length,
      itemBuilder: (context, index) {
        final filteredTasks = tasksView
            .where((task) => task.subject?.subjectCode == subjects[index])
            .toList();

        return filteredTasks.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                      child: Text(
                        subjects[index]!,
                        style: GoogleFonts.openSans(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredTasks.length,
                      itemBuilder: (context, idx) {
                        final task = filteredTasks[idx];
                        return SizedBox(
                          // height: 120,
                          child: TaskCard(
                            isByDate: false, 
                            task: task
                          ),
                        );
                      },
                    ),
                  ],
                ),
              )
            : Container(); // If no subjects for the day, return an empty Container
      },
      // itemCount: tasksView.length,
      // itemBuilder: (context, index) {
      //   final task = tasksView[index];
      //   return SizedBox(
      //     // height: 120,
      //     child: TaskCard(
      //       isByDate: false, 
      //       task: task
      //     ),
      //   );
      // },
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
