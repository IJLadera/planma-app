import 'package:flutter/material.dart';
import 'package:planma_app/Providers/goal_progress_provider.dart';
import 'package:planma_app/goals/view_goal.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:planma_app/models/goals_model.dart';
import 'package:provider/provider.dart';

class GoalCard extends StatelessWidget {
  final Goal goal;
  final double progress;

  const GoalCard({super.key, required this.goal, required this.progress});

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
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GoalDetailScreen(goal: goal),
              ),
            );
          },
          child: buildCardContents(progress),
        ),
      ),
    );
  }

  Widget buildCardContents(double progress) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFD7C0F3).withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 70,
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
                    fontSize: 16,
                    color: const Color(0xFF173F70),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${goal.timeframe} Goal',
                  style: GoogleFonts.openSans(
                    fontSize: 12,
                    color: const Color(0xFF173F70),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${goal.targetHours} hours',
                  style: GoogleFonts.openSans(
                    fontSize: 12,
                    color: const Color(0xFF173F70),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 60,
            height: 60,
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
    );
  }
}

