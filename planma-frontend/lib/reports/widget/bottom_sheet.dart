import 'package:flutter/material.dart';
import 'package:planma_app/activities/activity_page.dart';
import 'package:planma_app/event/event_page.dart';
import 'package:planma_app/goals/goal_page.dart';
import 'package:planma_app/reports/event_report_page.dart';
import 'package:planma_app/reports/task_report_page.dart';
import 'package:planma_app/task/task_page.dart';

class BottomSheetWidget {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return BottomSheetContent();
      },
    );
  }
}

class BottomSheetContent extends StatefulWidget {
  @override
  _BottomSheetContentState createState() => _BottomSheetContentState();
}

class _BottomSheetContentState extends State<BottomSheetContent> {
  String? selectedOption = "Task";

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Text(
                "Categories",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 16),
            _buildRadioTile(
              title: "Task",
              value: "Task",
              onChanged: (value) {
                setState(() => selectedOption = value);
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => ReportPage()),
                // );
              },
            ),
            _buildRadioTile(
              title: "Event",
              value: "Event",
              onChanged: (value) {
                setState(() => selectedOption = value);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EventReportsPage()),
                );
              },
            ),
            _buildRadioTile(
              title: "Goal",
              value: "Goal",
              onChanged: (value) {
                setState(() => selectedOption = value);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GoalPage()),
                );
              },
            ),
            _buildRadioTile(
              title: "Activity",
              value: "Activity",
              onChanged: (value) {
                setState(() => selectedOption = value);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ActivitiesScreen()),
                );
              },
            ),
            _buildRadioTile(
              title: "Sleep",
              value: "Sleep",
              onChanged: (value) {
                setState(() => selectedOption = value);
                // Uncomment when SleepPage is implemented
                // Navigator.push(context, MaterialPageRoute(builder: (context) => SleepPage()));
              },
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build a RadioListTile
  Widget _buildRadioTile({
    required String title,
    required String value,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      children: [
        RadioListTile<String>(
          title: Text(title),
          value: value,
          groupValue: selectedOption,
          onChanged: onChanged,
          controlAffinity: ListTileControlAffinity.trailing, // Radio at the end
        ),
        if (title != "Sleep") // No divider below the last option
          Divider(
            thickness: 1,
            color: Colors.grey.shade300,
          ),
      ],
    );
  }
}
