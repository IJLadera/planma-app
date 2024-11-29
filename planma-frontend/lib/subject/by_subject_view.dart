// by_subject_view.dart
import 'package:flutter/material.dart';
import 'package:planma_app/subject/widget/subject_card.dart'; // Import the SubjectCard widget

class BySubjectView extends StatelessWidget {
  final List<Map<String, String>> subjectsView;

  const BySubjectView({
    Key? key,
    required this.subjectsView,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: subjectsView.length,
      itemBuilder: (context, index) {
        final subject = subjectsView[index];
        return SizedBox(
          height: 120, // Adjust height as needed
          child: SubjectCard(
            isByDate: false,
            subject_code: subject['code']!,
            subject_title: subject['name']!,
            semester: subject['semester']!,
            start_time: subject['start_time']!,
            end_time: subject['end_time']!,
            room: subject['room']!,
            selected_days: subject['day']!,
          ),
        );
      },
    );
  }
}
