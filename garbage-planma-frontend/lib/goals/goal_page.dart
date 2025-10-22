import 'package:flutter/material.dart';
import 'package:planma_app/Providers/goal_progress_provider.dart';
import 'package:planma_app/Providers/goal_provider.dart';
import 'package:planma_app/goals/widget/search_bar.dart';
import 'package:planma_app/goals/create_goal.dart';
import 'package:planma_app/goals/widget/goal_card.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:planma_app/models/goals_model.dart';
import 'package:provider/provider.dart';

class GoalPage extends StatefulWidget {
  const GoalPage({super.key});

  @override
  State<GoalPage> createState() => _GoalPageState();
}

class _GoalPageState extends State<GoalPage> {
  List<Goal> filteredGoals = [];
  Map<int, double> progressData = {}; // Map for storing progress per goal ID

  @override
  void initState() {
    super.initState();
    _fetchAllData();
  }

  Future<void> _fetchAllData() async {
    final goalProvider = Provider.of<GoalProvider>(context, listen: false);
    final progressProvider = Provider.of<GoalProgressProvider>(context, listen: false);

    await goalProvider.fetchGoals();
    for (var goal in goalProvider.goals) {
      try {
        await progressProvider.fetchGoalProgressPerGoal(goal);
        final progress = progressProvider.computeProgress(
            goal.goalId!, goal.targetHours, goal.timeframe);
        setState(() {
          progressData[goal.goalId!] = progress;
        });
      } catch (e) {
        print('Error fetching progress for goal ${goal.goalId}: $e');
      }
    }

    setState(() {
      filteredGoals = goalProvider.goals;
    });
  }

  // void _filterGoals(String query) {
  //   final goalProvider = Provider.of<GoalProvider>(context, listen: false);
  //   final results = goalProvider.goals
  //       .where(
  //         (goal) => goal.goalName.toLowerCase().contains(query.toLowerCase()),
  //       )
  //       .toList();
  //   setState(() {
  //     filteredGoals = results;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Consumer<GoalProvider>(builder: (context, goalProvider, child) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF173F70)),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            'Goals',
            style: GoogleFonts.openSans(
              color: const Color(0xFF173F70),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: CustomSearchBar(),
            ),
            Expanded(
              child: filteredGoals.isNotEmpty
                  ? ListView.builder(
                      itemCount: filteredGoals.length,
                      itemBuilder: (context, index) {
                        final goal = filteredGoals[index];
                        final progress = progressData[goal.goalId] ?? 0.0;
                        return GoalCard(goal: goal, progress: progress);
                      },
                    )
                  : Center(
                      child: Text(
                        'No goals found',
                        style: GoogleFonts.openSans(
                          color: const Color(0xFF173F70),
                        ),
                      ),
                    ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddGoalScreen()),
            );
          },
          backgroundColor: const Color(0xFF173F70),
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      );
    });
  }
}
