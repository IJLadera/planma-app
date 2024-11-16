import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:planma_app/activities/activity_page.dart';
import 'package:planma_app/event/event_page.dart';
import 'package:planma_app/subject/subject_page.dart';
import 'package:planma_app/task/task_page.dart';

class BottomSheetWidget {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildBottomSheetButton(
                context,
                icon: Icons.check_circle,
                label: "Task",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TasksPage()),
                  );
                },
              ),
              _buildBottomSheetButton(
                context,
                icon: Icons.event,
                label: "Event",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EventsPage()),
                  );
                },
              ),
              _buildBottomSheetButton(
                context,
                icon: Icons.schedule,
                label: "Class Schedule",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ClassSchedule()),
                  );
                },
              ),
              _buildBottomSheetButton(
                context,
                icon: Icons.accessibility,
                label: "Activity",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ActivitiesScreen()),
                  );
                },
              ),
              _buildBottomSheetButton(
                context,
                icon: FontAwesomeIcons.flag,
                label: "Goal",
                onPressed: () {
                  // Navigate to Goals page
                },
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildBottomSheetButton(
      BuildContext context, {
        required IconData icon,
        required String label,
        required VoidCallback onPressed,
      }) {
    return ListTile(
      leading: Icon(icon, size: 30, color: Colors.blue),
      title: Text(
        label,
        style: TextStyle(fontSize: 18),
      ),
      onTap: onPressed,
    );
  }
}
