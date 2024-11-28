import 'package:flutter/material.dart';
import 'package:planma_app/activities/view_activity.dart';
import 'package:planma_app/timer/countdown/countdown_timer.dart';

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
                    color: Colors.blue,
                    size: 30,
                  ),
                  onPressed: () {
                    // Navigate to TimerPage
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TimerPage(themeColor: Colors.redAccent),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 10), // Spacing between button and text
                // Activity Details
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activityName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 11, 54, 89),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      timePeriod,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600], // Styling the timePeriod
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
