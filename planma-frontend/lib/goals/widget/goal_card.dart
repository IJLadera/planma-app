import 'package:flutter/material.dart';
import 'package:planma_app/goals/view_goal.dart';
import 'package:google_fonts/google_fonts.dart';

class GoalCard extends StatelessWidget {
  final String goalName;
  final int targetHours;
  final double progress;

  const GoalCard({
    super.key,
    required this.goalName,
    required this.targetHours,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        elevation: 5,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ViewGoal(
                  goalDetails: {
                    "Name": goalName,
                    "Target Hours": targetHours.toString(),
                    "Progress": "${(progress * 100).toInt()}%"
                  },
                  sessions: [],
                  filteredGoals: [],
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: const Color(0xFFD7C0F3).withOpacity(0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Vertical Divider
                Container(
                  height: 60,
                  width: 2,
                  color: const Color(0xFFB480F3),
                ),
                const SizedBox(width: 12),

                // Goal Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goalName,
                        style: GoogleFonts.openSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF173F70),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Target Hours: $targetHours',
                        style: GoogleFonts.openSans(
                          fontSize: 14,
                          color: const Color(0xFF173F70),
                        ),
                      ),
                    ],
                  ),
                ),

                // Circular Progress Indicator
                SizedBox(
                  width: 50,
                  height: 50,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey[300],
                        color: const Color(0xFFB480F3),
                        strokeWidth: 6,
                      ),
                      Center(
                        child: Text(
                          '${(progress * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF173F70),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
