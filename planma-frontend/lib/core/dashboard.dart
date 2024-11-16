import 'package:flutter/material.dart';
import 'package:planma_app/subject/subject_page.dart';
import 'package:planma_app/task/by_date_view.dart';
import 'package:planma_app/task/task_page.dart';
import 'package:planma_app/timetable/calendar.dart';
import 'package:planma_app/timetable/timetable.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class Dashboard extends StatelessWidget {
  final String username;

  const Dashboard({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hello, $username',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 2,
        actions: [
          IconButton(
            icon: const CircleAvatar(
              backgroundColor: Colors.yellow,
              child: Icon(Icons.person, color: Colors.black),
            ),
            onPressed: () {
              //Navigate to profile
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Let's make a productive plan together",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            const Text(
              'Menu',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  MenuButton(
                    color: Colors.blue,
                    icon: Icons.check_circle,
                    title: 'Tasks',
                    subtitle: '4 tasks',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => TasksPage()),
                      );
                    },
                  ),
                  const SizedBox(height: 15),
                  MenuButton(
                    color: Colors.teal,
                    icon: Icons.schedule,
                    title: 'Class Schedule',
                    subtitle: '11 classes',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ClassSchedule()),
                      );
                    },
                  ),
                  const SizedBox(height: 15),
                  MenuButton(
                    color: Colors.orange,
                    icon: Icons.event,
                    title: 'Events',
                    subtitle: '1 event',
                    onPressed: () {
                      // Navigate to Events page
                    },
                  ),
                  const SizedBox(height: 15),
                  MenuButton(
                    color: Colors.redAccent,
                    icon: Icons.accessibility,
                    title: 'Activities',
                    subtitle: '1 activity',
                    onPressed: () {
                      // Navigate to Activities page
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: Container(
          height: 30.0, // Adjust the height as needed
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30.0),
              topRight: Radius.circular(30.0),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.home),
                  onPressed: () {
                    // Navigate to Home page
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () {
                    Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CustomCalendar()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Action for floating button
        },
        backgroundColor: Colors.blue,
        shape: const CircleBorder(),
        child: Icon(Icons.add),
      ),
    );
  }
}

class MenuButton extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onPressed;

  const MenuButton({super.key, 
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.all(30),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: onPressed,
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 30),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
