import 'package:flutter/material.dart';
import 'package:planma_app/subject/widget/subject_view.dart';
import 'package:planma_app/models/class_schedules_model.dart';

class SubjectCard extends StatelessWidget {
  final bool isByDate;
  final ClassSchedule schedule;

  // Constructor to accept the isByDate parameter and subject data
  const SubjectCard({
    super.key,
    required this.isByDate,
    required this.schedule,
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
                    classSchedule: schedule,
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
                      schedule.subjectCode,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Subject Title
                    Text(
                      schedule.subjectTitle,
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
                        'Time: ${schedule.scheduledStartTime} - ${schedule.scheduledEndTime}',
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
