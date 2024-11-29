// by_date_view.dart
import 'package:flutter/material.dart';
import 'package:planma_app/subject/widget/subject_card.dart'; // Import the SubjectCard widget

class ByDateView extends StatelessWidget {
  final List<String> days;
  final List<Map<String, String>> subjectsView;

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
        final filteredSubjects = subjectsView
            .where((subject) => subject['day'] == days[index])
            .toList();

        return filteredSubjects.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 16.0, right: 16.0), // Adjust the margins here
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
                        final subject = filteredSubjects[idx];
                        return SizedBox(
                          height: 120, // Adjust height as needed
                          child: SubjectCard(
                            isByDate: true,
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
                    ),
                  ],
                ),
              )
            : Container(); // If no subjects for the day, return empty Container
      },
    );
  }
}
