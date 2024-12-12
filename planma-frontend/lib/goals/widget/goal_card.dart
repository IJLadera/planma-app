import 'package:flutter/material.dart';
import 'package:planma_app/goals/view_goal.dart';
import 'package:google_fonts/google_fonts.dart';

class GoalCard extends StatelessWidget {
  final String goalName;
  final int targetHours;
  final double progress;
  final Map<String, dynamic> goalDetails;

  const GoalCard({
    super.key,
    required this.goalName,
    required this.targetHours,
    required this.progress,
    required this.goalDetails,
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
                  goalDetails: goalDetails,
                  sessions: [
                    {"sessionName": "UI Design", "hoursSpent": 5},
                    {"sessionName": "Backend Setup", "hoursSpent": 8},
                  ],
                  filteredGoals: [
                    {
                      "name": "Subtask 1",
                      "targetHours": 5,
                      "progress": 0.5,
                    },
                    {
                      "name": "Subtask 2",
                      "targetHours": 3,
                      "progress": 0.8,
                    },
                  ],
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
                Container(
                  height: 60,
                  width: 2,
                  color: const Color(0xFFB480F3),
                ),
                const SizedBox(width: 12),
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
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF173F70),
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
