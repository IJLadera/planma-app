import 'package:flutter/material.dart';
import 'package:planma_app/activities/activity_page.dart';
import 'package:planma_app/event/event_page.dart';
import 'package:planma_app/subject/subject_page.dart';
import 'package:planma_app/task/task_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Dashboard extends StatelessWidget {
  final String username;

  Dashboard({required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hello, $username',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 2,
        actions: [
          IconButton(
            icon: CircleAvatar(
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
            Text(
              "Let's make a productive plan together",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 20),
            Text(
              'Menu',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
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
                  SizedBox(height: 15),
                  MenuButton(
                    color: Colors.teal,
                    icon: Icons.schedule,
                    title: 'Class Schedule',
                    subtitle: '11 classes',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ClassSchedule()),
                      );
                    },
                  ),
                  SizedBox(height: 15),
                  MenuButton(
                    color: Colors.orange,
                    icon: Icons.event,
                    title: 'Events',
                    subtitle: '1 event',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EventsPage()),
                      );
                    },
                  ),
                  SizedBox(height: 15),
                  MenuButton(
                    color: Colors.redAccent,
                    icon: Icons.accessibility,
                    title: 'Activities',
                    subtitle: '1 activity',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ActivitiesScreen()),
                      );
                    },
                  ),
                  SizedBox(height: 15),
                  // Add the "Goals" button
                  MenuButton(
                    color: Colors.purple,
                    icon: FontAwesomeIcons.flag,
                    title: 'Goals',
                    subtitle: '1 goal',
                    onPressed: () {
                      // Navigate to Goals page
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: Container(
          height: 30.0, // Adjust the height as needed
          decoration: BoxDecoration(
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
                  icon: Icon(Icons.home),
                  onPressed: () {
                    // Navigate to Home page
                  },
                ),
                IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () {
                    // Navigate to Calendar
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
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
        shape: CircleBorder(),
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

  MenuButton({
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
        padding: EdgeInsets.all(30),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: onPressed,
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 30),
          SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              Text(
                subtitle,
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
