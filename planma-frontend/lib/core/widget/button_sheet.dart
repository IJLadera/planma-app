import 'package:flutter/material.dart';
import 'package:planma_app/activities/activity_page.dart';
import 'package:planma_app/event/event_page.dart';
import 'package:planma_app/goals/goal_page.dart';
import 'package:planma_app/reports/report_page.dart';
import 'package:planma_app/subject/subject_page.dart';
import 'package:planma_app/task/task_page.dart';

class BottomSheetWidget {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      isScrollControlled:
          true, // Allows the bottom sheet to expand when content is long
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
          child: SingleChildScrollView(
            // Makes the content scrollable
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Centered "Add" label
                Center(
                  child: Text(
                    "Add",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Task button
                _buildBottomSheetButton(
                  context,
                  label: "Task",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TasksPage()),
                    );
                  },
                ),

                // Event button
                _buildBottomSheetButton(
                  context,
                  label: "Event",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EventsPage()),
                    );
                  },
                ),

                // Class Schedule button
                _buildBottomSheetButton(
                  context,
                  label: "Class Schedule",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ClassSchedule()),
                    );
                  },
                ),

                // Activity button
                _buildBottomSheetButton(
                  context,
                  label: "Activity",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ActivitiesScreen()),
                    );
                  },
                ),

                // Goal button
                _buildBottomSheetButton(
                  context,
                  label: "Goal",
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => GoalPage()));
                  },
                ),
                _buildBottomSheetButton(
                  context,
                  label: "Sleep",
                  onPressed: () {
                    // Navigator.push(context,
                    //     MaterialPageRoute(builder: (context) => SleepPage()));
                  },
                ),
                _buildBottomSheetButton(
                  context,
                  label: "Report",
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => ReportsPage()));
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper method for buttons
  static Widget _buildBottomSheetButton(
    BuildContext context, {
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        ListTile(
          title: Center(
            child: Text(
              label,
              style: TextStyle(fontSize: 18),
            ),
          ),
          onTap: onPressed,
        ),
        if (label != "Add") // Exclude divider below "Add"
          Divider(
            thickness: 1,
            color: Colors.grey.shade300,
          ),
      ],
    );
  }
}
