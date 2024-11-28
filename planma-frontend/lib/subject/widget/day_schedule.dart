import 'package:flutter/material.dart';
import 'package:planma_app/subject/widget/subject_card.dart'; // Import the SubjectCard

class DaySchedule extends StatelessWidget {
  final String day;
  final bool isByDate;

  DaySchedule({super.key, required this.day, required this.isByDate});

  // Example list of subjects
  final List<Map<String, dynamic>> subjects = [
    {
      'code': 'MATH101',
      'name': 'Calculus I',
      'start_time': '9:00 AM',
      'end_time': '10:30 AM',
      'room': 'Room 101',
      'selected_days': 'Mon, Wed, Fri'
    },
    {
      'code': 'PHYS102',
      'name': 'Physics I',
      'start_time': '11:00 AM',
      'end_time': '12:30 PM',
      'room': 'Room 102',
      'selected_days': 'Mon, Wed, Fri'
    },
    {
      'code': 'CS103',
      'name': 'Intro to Programming',
      'start_time': '2:00 PM',
      'end_time': '3:30 PM',
      'room': 'Room 103',
      'selected_days': 'Tue, Thu'
    },
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
          const SizedBox(height: 5),
          // Using ListView to ensure scrollable and fixed size for each card
          ListView.builder(
            shrinkWrap: true, // Prevents ListView from taking up infinite space
            physics:
                NeverScrollableScrollPhysics(), // Ensures parent scrolls, not the ListView
            itemCount: subjects.length,
            itemBuilder: (context, index) {
              var subject = subjects[index];
              return SizedBox(
                height: 120, // Fixed height for each card
                child: SubjectCard(
                  isByDate: isByDate,
                  subject_code: subject['code'],
                  subject_title: subject['name'],
                  semester: '2024', // Placeholder for semester
                  start_time: subject['start_time'],
                  end_time: subject['end_time'],
                  room: subject['room'],
                  selected_days: subject['selected_days'],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
