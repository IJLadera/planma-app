import 'package:flutter/material.dart';
import 'package:planma_app/goals/create_goal.dart';
import 'package:planma_app/goals/widget/goal_card.dart';
import 'package:google_fonts/google_fonts.dart';

class GoalPage extends StatefulWidget {
  const GoalPage({super.key});

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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddGoalScreen()),
          );
        },
        backgroundColor: Color(0xFF173F70),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
