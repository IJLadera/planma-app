import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:planma_app/activities/view_activity.dart';
import 'package:planma_app/timer/clock.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:planma_app/models/activity_model.dart';

class ActivityCard extends StatelessWidget {
  final Activity activity;
  final bool isByDate;

  const ActivityCard({
    super.key,
    required this.isByDate,
    required this.activity,
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
    final startTime = _formatTimeForDisplay(activity.scheduledStartTime);
    final endTime = _formatTimeForDisplay(activity.scheduledEndTime);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
              12.0), // Rounded corners for a smoother look
        ),
        elevation: 5, // Adds shadow for visual appeal
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ActivityDetailScreen(activity: activity),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Color(0xFFFBA2A2)
                  .withOpacity(0.6), // Slight transparency for the background
              borderRadius: BorderRadius.circular(12), // Rounded corners
            ),
            child: Row(
              children: [
                // Play Button at the start
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ClockScreen(
                            themeColor: Color(0xFFFBA2A2), title: "Activity"),
                      ),
                    );
                  },
                  child: const Icon(
                    Icons.play_circle_fill,
                    color: Color(0xFF173F70),
                    size: 40,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  height: 50, // The height of the divider, adjust as needed
                  width: 2, // The thickness of the divider
                  color: Color(0xFFFF5656), // Divider color
                ),
                const SizedBox(width: 12),
                // Activity Details
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.activityName,
                      style: GoogleFonts.openSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF173F70),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '$startTime - $endTime',
                      style: GoogleFonts.openSans(
                        fontSize: 14,
                        color: Color(0xFF173F70),
                      ),
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
