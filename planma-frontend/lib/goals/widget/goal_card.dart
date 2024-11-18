import 'package:flutter/material.dart';
import 'package:planma_app/goals/view_goal.dart';

class GoalCard extends StatelessWidget {
  final String goalName;
  final int targetHours;
  final double progress;

  const GoalCard({
    Key? key,
    required this.goalName,
    required this.targetHours,
    required this.progress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.purple[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16.0),
          title: Text(
            goalName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Target Hours: $targetHours',
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ViewGoal(
                  goalName: goalName,
                  targetHours: targetHours,
                  progress: progress,
                ),
              ),
            );
          },
          trailing: SizedBox(
            width: 50,
            height: 50,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[300],
                  color: Colors.purple,
                  strokeWidth: 6,
                ),
                Center(
                  child: Text(
                    '${(progress * 100).toInt()}%',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
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
