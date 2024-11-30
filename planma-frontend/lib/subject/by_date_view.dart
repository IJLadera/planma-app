// by_date_view.dart
import 'package:flutter/material.dart';
import 'package:planma_app/subject/widget/subject_card.dart';
import 'package:planma_app/models/class_schedules_model.dart';

class ByDateView extends StatelessWidget {
  final List<String> days;
  final List<ClassSchedule> subjectsView;

  const ByDateView({
    Key? key,
    required this.days,
    required this.subjectsView,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: days.length,
      itemBuilder: (context, index) {
        // Filter ClassSchedule objects by day
        final filteredSubjects = subjectsView
            .where((schedule) => schedule.dayOfWeek == days[index])
            .toList();

        return filteredSubjects.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                      child: Text(
                        days[index], // The day name
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredSubjects.length,
                      itemBuilder: (context, idx) {
                        final schedule = filteredSubjects[idx];
                        return SizedBox(
                          height: 120, // Adjust height as needed
                          child: SubjectCard(
                            isByDate: true,
                            schedule: schedule,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              )
            : Container(); // If no subjects for the day, return an empty Container
      },
    );
  }
}
