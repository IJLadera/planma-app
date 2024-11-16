import 'package:flutter/material.dart';
import 'package:planma_app/activities/view_activity.dart';

class EventCard extends StatelessWidget {
  final String activityName;
  final String timePeriod;
  final Color backgroundColor;

  const EventCard({
    Key? key,
    required this.activityName,
    required this.timePeriod,
    required this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ViewActivity(
                activityName: activityName,
                description: 'Sample Description', // Replace with real data
                date: '2024-11-16', // Replace with real data
                time: timePeriod,
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
                    // Add functionality to play or start the activity
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
                          color: const Color.fromARGB(255, 11, 54, 89)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      timePeriod,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600], // This resolves the issue
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
