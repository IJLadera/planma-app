import 'package:flutter/material.dart';
import 'package:planma_app/subject/widget/subject_view.dart'; // Import the SubjectDetailScreen

class SubjectCard extends StatelessWidget {
  final bool isByDate;
  final String subject_code;
  final String subject_title;
  final String semester;
  final String start_time;
  final String end_time;
  final String room;
  final String selected_days;

  // Constructor to accept the isByDate parameter and subject data
  const SubjectCard({
    Key? key,
    required this.isByDate,
    required this.subject_code,
    required this.subject_title,
    required this.semester,
    required this.start_time,
    required this.end_time,
    required this.room,
    required this.selected_days,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Card(
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SubjectDetailScreen(
                  subject_code: subject_code,
                  subject_title: subject_title,
                  semester: semester,
                  start_time: start_time,
                  end_time: end_time,
                  room: room,
                  selected_days: selected_days,
                ),
              ),
            );
          },
          child: Container(
            padding: EdgeInsets.all(14.0),
            decoration: BoxDecoration(
              color: Colors.lightGreenAccent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject_code,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  start_time,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
