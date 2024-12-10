import 'package:flutter/material.dart';
import 'package:planma_app/activities/view_activity.dart';
import 'package:planma_app/timer/countdown/countdown_timer.dart';
import 'package:google_fonts/google_fonts.dart';

class ActivityCard extends StatelessWidget {
  final String activityName;
  final String timePeriod;
  final String description;
  final String date;
  final Color backgroundColor;

  const ActivityCard({
    Key? key,
    required this.activityName,
    required this.timePeriod,
    required this.description,
    required this.date,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
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
                builder: (context) => ViewActivity(
                  activityName: activityName,
                  description: description,
                  date: date,
                  time: timePeriod,
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: backgroundColor
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
                        builder: (context) =>
                            const TimerPage(themeColor: Color(0xFFFBA2A2)),
                      ),
                    );
                  },
                  child: const Icon(
                    Icons.play_circle_fill,
                    color: Color(0xFF173F70),
                    size: 28,
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
                      activityName,
                      style: GoogleFonts.openSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF173F70),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      timePeriod,
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
