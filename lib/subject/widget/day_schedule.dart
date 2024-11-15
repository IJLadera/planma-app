import 'package:flutter/material.dart';
import 'package:planma_app/subject/widget/subject_card.dart'; // Import the SubjectCard widget

class DaySchedule extends StatelessWidget {
  final String day;
  final bool isByDate;

  // Constructor to accept the day and isByDate parameters
  DaySchedule({required this.day, required this.isByDate});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            day,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          // Generate a list of SubjectCard widgets
          ...List.generate(
            3,
            (index) => SubjectCard(isByDate: isByDate),
          ).toList(),
        ],
      ),
    );
  }
}
