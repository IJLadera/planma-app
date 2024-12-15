import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:planma_app/subject/widget/subject_view.dart';
import 'package:planma_app/models/class_schedules_model.dart';
import 'package:google_fonts/google_fonts.dart';

class SubjectCard extends StatelessWidget {
  final bool isByDate;
  final ClassSchedule schedule;

  // Constructor to accept the isByDate parameter and subject data
  const SubjectCard({
    super.key,
    required this.isByDate,
    required this.schedule,
  });

  String _formatTimeForDisplay(String time24) {
    final timeParts = time24.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    final timeOfDay = TimeOfDay(hour: hour, minute: minute);

    // Format to "H:mm a"
    final now = DateTime.now();
    final dateTime = DateTime(
      now.year,
      now.month,
      now.day,
      timeOfDay.hour,
      timeOfDay.minute,
    );
    return DateFormat.jm().format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final startTime = _formatTimeForDisplay(schedule.scheduledStartTime);
    final endTime = _formatTimeForDisplay(schedule.scheduledEndTime);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0), // Rounded corners
        ),
        elevation: 5, // Adds shadow effect for better UX
        child: InkWell(
          borderRadius: BorderRadius.circular(12.0),
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
              color: const Color(0xFFFFE1BF)
                  .withOpacity(0.6), // Slight transparency
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row for Divider and Subject Details
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(width: 3, height: 10),

                    // Divider
                    Container(
                      height: 70, // Height of the divider
                      width: 2, // Thickness of the divider
                      color: const Color(0xFFFFBB70), // Divider color
                    ),
                    const SizedBox(
                      width: 12,
                      height: 5,
                    ),
                    // Subject Details
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Subject Code
                        Text(
                          schedule.subjectCode,
                          style: GoogleFonts.openSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF173F70),
                          ),
                        ),
                        const SizedBox(
                          width: 12,
                          height: 5,
                        ),
                        // Subject Title
                        Text(
                          schedule.subjectTitle,
                          style: GoogleFonts.openSans(
                            fontSize: 12,
                            color: const Color(0xFF173F70),
                          ),
                        ),
                        const SizedBox(
                          width: 12,
                          height: 5,
                        ),
                        // Time Info
                        Text(
                          '$startTime - $endTime',
                          style: GoogleFonts.openSans(
                            fontSize: 12,
                            color: const Color(0xFF173F70),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
