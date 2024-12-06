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
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: () {
          // Navigate to ViewActivity screen and pass dynamic data
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ViewActivity(
                activityName: activityName,
                description: description, // Passing real description data
                date: date, // Passing real date data
                time: timePeriod, // Passing real time data
              ),
            ),
          );
        },
        child: SizedBox(
          width: double.infinity, // Make the card fill the available width
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                // Play Button at Start
                IconButton(
                  icon: const Icon(
                    Icons.play_circle_fill,
                    color: Color(0xFF173F70),
                    size: 30,
                  ),
                  onPressed: () {
                    // Navigate to TimerPage
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const TimerPage(themeColor: Color(0xFFFBA2A2)),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 16), // Spacing between button and text
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
