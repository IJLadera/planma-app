import 'package:flutter/material.dart';
import 'package:planma_app/goals/edit_goal.dart';
import 'package:planma_app/goals/edit_goal_session.dart';
import 'package:planma_app/goals/widget/goal_card.dart';
import 'package:planma_app/goals/widget/goal_detail_row.dart';

class ViewGoal extends StatelessWidget {
  final Map<String, dynamic> goalDetails;
  final List<Map<String, dynamic>> sessions;
  final List<Map<String, dynamic>> filteredGoals;

  const ViewGoal({
    super.key,
    required this.goalDetails,
    required this.sessions,
    required this.filteredGoals,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.blue),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditGoal()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.blue),
            onPressed: () {
              // Show confirmation dialog before deletion
            },
          ),
        ],
        centerTitle: true,
        title: const Text(
          'Goal',
          style: TextStyle(
            color: Colors.black,
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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Displaying goal details using GoalDetailRow
                GoalDetailRow(
                  label: 'Goal Code:',
                  value: goalDetails['goalCode'] ?? 'N/A',
                ),
                GoalDetailRow(
                  label: 'Description:',
                  value: goalDetails['description'] ?? 'No Description',
                ),
                GoalDetailRow(
                  label: 'Timeframe:',
                  value: goalDetails['timeFrame'] ?? 'N/A',
                ),
                GoalDetailRow(
                  label: 'Target Hours:',
                  value: goalDetails['targetDuration']?.toString() ?? 'N/A',
                ),
                GoalDetailRow(
                  label: 'Type:',
                  value: goalDetails['goalType'] ?? 'N/A',
                ),
                GoalDetailRow(
                  label: 'Semester:',
                  value: goalDetails['semester'] ?? 'N/A',
                ),
                const SizedBox(height: 16),

                // Sessions Section
                const Center(
                  child: Text(
                    'Sessions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                sessions.isNotEmpty
                    ? Expanded(
                        child: filteredGoals.isNotEmpty
                            ? ListView.builder(
                                itemCount: filteredGoals.length,
                                itemBuilder: (context, index) {
                                  final goal = filteredGoals[index];
                                  return GoalCard(
                                    goalName: goal['name'],
                                    targetHours: goal['targetHours'],
                                    progress: goal['progress'],
                                  );
                                },
                              )
                            : const Center(
                                child: Text(
                                  'No goals found',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                      )
                    :
                    // Add Session Button
                    Align(
                        alignment: Alignment.center,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditGoalSession(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 24),
                          ),
                          child: const Text(
                            'Add Session',
                            style: TextStyle(fontSize: 16, color: Colors.white),
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
