import 'package:flutter/material.dart';
import 'package:planma_app/subject/widget/subject_card.dart';

class DaySchedule extends StatelessWidget {
  final String day;
  final bool isByDate;

  DaySchedule({super.key, required this.day, required this.isByDate});

  // Example list of subjects
  final List<Map<String, dynamic>> subjects = [
    {'code': 'MATH101', 'name': 'Calculus I', 'time': '9:00 AM - 10:30 AM'},
    {'code': 'PHYS102', 'name': 'Physics I', 'time': '11:00 AM - 12:30 PM'},
    {'code': 'CS103', 'name': 'Intro to Programming', 'time': '2:00 PM - 3:30 PM'},
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            day,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...subjects.map((subject) => SubjectCard(isByDate: isByDate, subject: subject)).toList(),
        ],
      ),
    );
  }
}
