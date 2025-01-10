import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:planma_app/goals/view_goal_session.dart';
import 'package:planma_app/models/goal_schedules_model.dart';

class GoalSessionCard extends StatelessWidget {
  final GoalSchedule session;

  const GoalSessionCard({super.key, required this.session});

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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.0),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GoalSessionDetailScreen(session: session),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFE0E0E0),
            borderRadius: BorderRadius.circular(20.0),
          ),
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Play Icon
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF173F70), // Icon background color
                ),
                padding: const EdgeInsets.all(8.0),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              // Vertical Divider
              Container(width: 1.5, height: 30, color: Colors.grey),
              const SizedBox(width: 12),
              // Session Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.goal!.goalName,
                      style: GoogleFonts.openSans(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF173F70),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          DateFormat('MM/dd/yyyy')
                              .format(DateTime.parse(session.scheduledDate)),
                          style: GoogleFonts.openSans(
                            color: const Color(0xFF173F70),
                            fontSize: 14,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          "(${_formatTimeForDisplay(session.scheduledStartTime)} - ${_formatTimeForDisplay(session.scheduledEndTime)})",
                          style: GoogleFonts.openSans(
                            color: const Color(0xFF173F70),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
