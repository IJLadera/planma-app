import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:planma_app/Providers/goal_schedule_provider.dart';
import 'package:planma_app/goals/edit_goal_session.dart';
import 'package:planma_app/goals/widget/goal_detail_row.dart';
import 'package:planma_app/models/goal_schedules_model.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class GoalSessionDetailScreen extends StatefulWidget {
  final GoalSchedule session;

  const GoalSessionDetailScreen(
      {super.key, required this.session});

  @override
  State<GoalSessionDetailScreen> createState() =>
      _GoalSessionDetailScreenState();
}

class _GoalSessionDetailScreenState extends State<GoalSessionDetailScreen> {
  void _handleDelete(BuildContext context) async {
    final provider = Provider.of<GoalScheduleProvider>(context, listen: false);
    final isConfirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Goal Session'),
        content:
            const Text('Are you sure you want to delete this goal session?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (isConfirmed == true) {
      provider.deleteGoalSchedule(widget.session.goalScheduleId!);
      Navigator.pop(context);
    }
  }

  String _formatTimeForDisplay(String time24) {
    final timeParts = time24.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    final timeOfDay = TimeOfDay(hour: hour, minute: minute);

    // Format to "H:mm a"
    final now = DateTime.now();
    final dateTime = DateTime(
      now.year,
      now.month,
      now.day,
      timeOfDay.hour,
      timeOfDay.minute,
    );
    return DateFormat.jm().format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GoalScheduleProvider>(
        builder: (context, scheduleProvider, child) {
      final session = scheduleProvider.goalschedules.firstWhere(
        (s) => s.goalScheduleId == widget.session.goalScheduleId,
      );

      if (session.goalScheduleId == null) {
        return Scaffold(
          appBar: AppBar(title: Text('Goal Schedule Details')),
          body: Center(child: Text('Goal Schedule not found')),
        );
      }

      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.close, color: Color(0xFF173F70)),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.edit, color: Color(0xFF173F70)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EditGoalSession(session: session)),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Color(0xFF173F70)),
              onPressed: () => _handleDelete(context),
            ),
          ],
          centerTitle: true,
          title: Text(
            'Goal Session',
            style: GoogleFonts.openSans(
              color: Color(0xFF173F70),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(9),
              color: Colors.grey[100],
            ),
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GoalDetailRow(
                    label: 'Goal Name:',
                    detail: session.goal!.goalName,
                  ),
                  const Divider(),
                  GoalDetailRow(
                    label: 'Scheduled Date:',
                    detail: DateFormat('dd MMMM yyyy')
                        .format(DateTime.parse(session.scheduledDate))
                        .toString(),
                  ),
                  const Divider(),
                  GoalDetailRow(
                    label: 'Scheduled Time:',
                    detail:
                        '${_formatTimeForDisplay(session.scheduledStartTime)} - ${_formatTimeForDisplay(session.scheduledEndTime)}',
                  ),
                  const Divider(),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
