// by_subject_view.dart
import 'package:flutter/material.dart';
import 'package:planma_app/models/class_schedules_model.dart';
import 'package:planma_app/subject/widget/subject_card.dart'; // Import the SubjectCard widget

class BySubjectView extends StatelessWidget {
  final List<ClassSchedule> subjectsView;

  const BySubjectView({
    Key? key,
    required this.subjectsView,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: subjectsView.length,
      itemBuilder: (context, index) {
        final schedule = subjectsView[index];
        return SizedBox(
          height: 120, // Adjust height as needed
          child: SubjectCard(
            isByDate: false,
            schedule: schedule,
          ),
        );
      },
    );
  }
}
