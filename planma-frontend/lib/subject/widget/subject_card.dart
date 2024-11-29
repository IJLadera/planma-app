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
    super.key,
    required this.isByDate,
    required this.subject_code,
    required this.subject_title,
    required this.semester,
    required this.start_time,
    required this.end_time,
    required this.room,
    required this.selected_days,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0), // Rounded corners
        ),
        elevation: 5, // Adds shadow effect for better UX
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
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.lightGreenAccent
                    .withOpacity(0.6), // Slight transparency
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Subject Code
                    Text(
                      subject_code,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Subject Title
                    Text(
                      subject_title,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Time Info
                    Row(children: [
                      Text(
                        'Time: $start_time - $end_time',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const Spacer(),
                    ]),
                  ]),
            )),
      ),
    );
  }
}
