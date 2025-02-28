import 'package:flutter/material.dart';
import 'package:planma_app/activities/create_activity.dart';
import 'package:planma_app/event/create_event.dart';
import 'package:planma_app/goals/create_goal.dart';
import 'package:planma_app/subject/create_subject.dart';
import 'package:planma_app/task/create_task.dart';
import 'package:google_fonts/google_fonts.dart';

class BottomSheetWidget {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25.0),
        ),
      ),
      isScrollControlled:
          true, // Allows the bottom sheet to expand when content is long
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Text(
                    "Add",
                    style: GoogleFonts.openSans(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF173F70),
                    ),
                  ),
                ),

                SizedBox(height: 16),

                // Task button
                _buildBottomSheetButton(
                  context,
                  label: "Task",
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddTaskScreen()),
                    );
                  },
                ),

                Divider(thickness: 1, color: Color(0xFF173F70)),

                // Class Schedule button
                _buildBottomSheetButton(
                  context,
                  label: "Class Schedule",
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddClassScreen()),
                    );
                  },
                ),

                Divider(thickness: 1, color: Color(0xFF173F70)),

                // Event button
                _buildBottomSheetButton(
                  context,
                  label: "Event",
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddEventScreen()),
                    );
                  },
                ),

                Divider(thickness: 1, color: Color(0xFF173F70)),

                // Activity button
                _buildBottomSheetButton(
                  context,
                  label: "Activity",
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AddActivityScreen()),
                    );
                  },
                ),

                Divider(thickness: 0.5, color: Color(0xFF173F70)),

                // Goal button
                _buildBottomSheetButton(
                  context,
                  label: "Goal",
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddGoalScreen()));
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
              style:
                  GoogleFonts.openSans(fontSize: 18, color: Color(0xFF173F70)),
            ),
          ),
          onTap: onPressed,
        ),
      ],
    );
  }
}
