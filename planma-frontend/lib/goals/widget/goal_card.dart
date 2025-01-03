import 'package:flutter/material.dart';
import 'package:planma_app/goals/view_goal.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:planma_app/models/goals_model.dart';

class GoalCard extends StatelessWidget {
  final Goal goal;
  final double progress = 0; 

  const GoalCard({
    super.key,
    required this.goal,
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
          borderRadius: BorderRadius.circular(12.0),
          onTap: () {
            // Navigate to GoalDetails page with dynamic data
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GoalDetailScreen(goal: goal),
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
                        goal.goalName,
                        style: GoogleFonts.openSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Target Hours: ${goal.targetHours}',
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
