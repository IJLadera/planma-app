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
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SubjectDetailScreen(
                    classSchedule: schedule,
                    classschedId: schedule.classschedId!,
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color:
                    Color(0xFFACEFDB).withOpacity(0.6), // Slight transparency
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Subject Code
                    Text(
                      schedule.subjectCode,
                      style: GoogleFonts.openSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 4),
                    // Subject Title
                    Text(
                      schedule.subjectTitle,
                      style: GoogleFonts.openSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF173F70),
                      ),
                    ),

                    const SizedBox(height: 4),
                    // Time Info
                    Row(children: [
                      Text(
                        '$startTime - $endTime',
                        style: GoogleFonts.openSans(
                          fontSize: 12,
                          color: Color(0xFF173F70),
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
