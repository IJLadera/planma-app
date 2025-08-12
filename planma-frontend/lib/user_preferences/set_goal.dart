import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:planma_app/user_preferences/finished.dart';
import 'package:planma_app/user_preferences/widget/create_goal.dart';
import 'package:planma_app/user_preferences/widget/goal_option.dart';

class GoalSelectionPage extends StatefulWidget {
  const GoalSelectionPage({super.key});

  @override
  State<GoalSelectionPage> createState() => _GoalSelectionPageState();
}

class _GoalSelectionPageState extends State<GoalSelectionPage> {
  int? selectedIndex;

  final List<String> goals = [
    'Study',
    'Gym Workout',
    'Practice a Skill',
    'Create Custom',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  "Let’s make things happen!",
                  style: GoogleFonts.openSans(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF173F70),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),

              // Subheading Text
              Center(
                child: Text(
                  "What’s the first goal you’d like to work toward?",
                  style: GoogleFonts.openSans(
                    fontSize: 16,
                    color: Color(0xFF173F70),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20), // Adjusted to reduce space
              Expanded(
                child: ListView(
                  shrinkWrap: true, // Allows ListView to occupy minimal height
                  children: [
                    GoalOptionTile(
                      title: "Study",
                      isSelected: selectedIndex == 0,
                      onTap: () => setState(() => selectedIndex = 0),
                    ),
                    GoalOptionTile(
                      title: "Gym Workout",
                      isSelected: selectedIndex == 1,
                      onTap: () => setState(() => selectedIndex = 1),
                    ),
                    GoalOptionTile(
                      title: "Practice a Skill",
                      isSelected: selectedIndex == 2,
                      onTap: () => setState(() => selectedIndex = 2),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const CreateGoal()),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.add, color: Color(0xFF173F70)),
                            const SizedBox(width: 8.0),
                            Text(
                              "Create Custom",
                              style: GoogleFonts.openSans(
                                fontSize: 16,
                                color: const Color(0xFF173F70),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (selectedIndex != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateGoal(
                          initialGoalName: goals[selectedIndex!], // Pass title
                        ),
                      ),
                    );
                  } else {
                    // Optionally show a snackbar or dialog if nothing is selected
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Please select a goal first")),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF173F70),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text(
                  "Next",
                  style:
                      GoogleFonts.openSans(fontSize: 18, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SuccessScreen(),
                      ),
                    );
                  },
                  child: Text(
                    "Skip for now",
                    style: GoogleFonts.openSans(
                      fontSize: 14,
                      color: Color(0xFF173F70),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
