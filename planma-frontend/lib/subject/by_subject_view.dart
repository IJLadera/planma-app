// by_subject_view.dart
import 'package:flutter/material.dart';
import 'package:planma_app/models/class_schedules_model.dart';
import 'package:planma_app/subject/widget/subject_card.dart';
import 'package:google_fonts/google_fonts.dart';

class BySubjectView extends StatelessWidget {
  final List<ClassSchedule> subjectsView;

  const BySubjectView({
    Key? key,
    required this.subjectsView,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<String> subjects = subjectsView
        .map((subject) => subject.subjectCode)
        .toSet() // Use a Set to remove duplicates
        .toList();

    print("Subjects List: $subjects");

    return ListView.builder(
      itemCount: subjects.length,
      itemBuilder: (context, index) {
        final filteredClasses = subjectsView
            .where((subject) => subject.subjectCode == subjects[index])
            .toList();

        
        return filteredClasses.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                      child: Text(
                        subjects[index],
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
                      itemCount: filteredClasses.length,
                      itemBuilder: (context, idx) {
                        final schedule = filteredClasses[idx];
                        return SizedBox(
                          // height: 120,
                          child: SubjectCard(
                            isByDate: false, 
                            schedule: schedule
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