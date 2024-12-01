import 'package:flutter/material.dart';
import 'package:planma_app/activities/create_activity.dart';
import 'package:planma_app/activities/view_activity.dart';
import 'package:planma_app/activities/widget/activity_card.dart';

class ActivitiesScreen extends StatelessWidget {
  ActivitiesScreen({Key? key}) : super(key: key);

  final List<Map<String, String>> activities = [
    {
      'name': 'Yoga Class',
      'time': '9:00 AM - 10:00 AM',
      'description': 'A relaxing yoga session.',
      'date': '2024-11-16',
    },
    {
      'name': 'Cooking Workshop',
      'time': '11:00 AM - 1:00 PM',
      'description': 'Learn to cook delicious dishes.',
      'date': '2024-11-18',
    },
    // Add more activities as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Activities',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            // Search Bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              onChanged: (value) {
                // TODO: Implement search functionality by filtering the activities list.
              },
            ),
            const SizedBox(height: 20),
            // List of Activities
            Expanded(
              child: ListView.builder(
                itemCount: activities.length,
                itemBuilder: (context, index) {
                  var activity = activities[index];
                  return GestureDetector(
                    onTap: () {
                      // Navigate to the ViewActivity screen and pass the selected activity data
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ViewActivity(
                            activityName: activity['name']!,
                            description: activity['description']!,
                            date: activity['date']!,
                            time: activity['time']!,
                          ),
                        ),
                      );
                    },
                    child: ActivityCard(
                      activityName: activity['name']!,
                      timePeriod: activity['time']!,
                      description: activity['description']!,
                      date: activity['date']!,
                      backgroundColor: const Color.fromARGB(255, 246, 136, 136),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddActivityScreen()),
          );
        },
        backgroundColor: const Color(0xFF173F70),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
