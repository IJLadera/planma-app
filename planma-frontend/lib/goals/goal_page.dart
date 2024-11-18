import 'package:flutter/material.dart';
import 'package:planma_app/goals/create_goal.dart';
import 'package:planma_app/goals/widget/goal_card.dart';

class GoalPage extends StatefulWidget {
  const GoalPage({Key? key}) : super(key: key);

  @override
  State<GoalPage> createState() => _GoalPageState();
}

class _GoalPageState extends State<GoalPage> {
  // Simulated list of goals. Replace this with database or API data.
  final List<Map<String, dynamic>> goals = [
    {"name": "Goal Name", "targetHours": 20, "progress": 0.25},
  ];

  // Filtered goals list for search functionality
  late List<Map<String, dynamic>> filteredGoals;

  @override
  void initState() {
    super.initState();
    filteredGoals = goals;
  }

  void _filterGoals(String query) {
    final results = goals
        .where(
            (goal) => goal['name'].toLowerCase().contains(query.toLowerCase()))
        .toList();
    setState(() {
      filteredGoals = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Goals',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            TextField(
              onChanged: _filterGoals,
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Goal Cards
            Expanded(
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
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddGoalScreen()),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
