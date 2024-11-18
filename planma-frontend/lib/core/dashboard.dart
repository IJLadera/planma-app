import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:planma_app/activities/activity_page.dart';
import 'package:planma_app/core/widget/button_sheet.dart';
import 'package:planma_app/core/widget/menu_button.dart';
import 'package:planma_app/event/event_page.dart';
import 'package:planma_app/goals/goal_page.dart';
import 'package:planma_app/subject/subject_page.dart';
import 'package:planma_app/task/task_page.dart';

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
              // Navigate to profile
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
                  MenuButtonWidget(
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
                  MenuButtonWidget(
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
                  MenuButtonWidget(
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
                  MenuButtonWidget(
                    color: Colors.redAccent,
                    icon: Icons.accessibility,
                    title: 'Activities',
                    subtitle: '1 activity',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ActivitiesScreen()),
                      );
                    },
                  ),
                  SizedBox(height: 15),
                  MenuButtonWidget(
                    color: Colors.purple,
                    icon: FontAwesomeIcons.flag,
                    title: 'Goals',
                    subtitle: '1 goal',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => GoalPage()),
                      );
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
          height: 60.0, // Adjusted height for better appearance
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          BottomSheetWidget.show(context);
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
        shape: CircleBorder(),
      ),
    );
  }
}
