import 'package:flutter/material.dart';

class GoalSelectionScreen extends StatelessWidget {
  const GoalSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  "Let’s make things happen!",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  "What’s the first goal you’d like to work toward?",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20), // Adjusted to reduce space
              Expanded(
                child: ListView(
                  shrinkWrap: true, // Allows ListView to occupy minimal height
                  children: [
                    GoalOptionTile(title: "Study for the Whole Semester"),
                    GoalOptionTile(title: "Exercise"),
                    GoalOptionTile(title: "Practice a Skill"),
                    GoalOptionTile(title: "Train for an Event"),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // Add navigation or functionality here
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  "Next",
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class GoalOptionTile extends StatefulWidget {
  final String title;

  const GoalOptionTile({super.key, required this.title});

  @override
  _GoalOptionTileState createState() => _GoalOptionTileState();
}

class _GoalOptionTileState extends State<GoalOptionTile> {
  bool _isSelected = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isSelected = !_isSelected;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: _isSelected ? Colors.indigo.withOpacity(0.1) : Colors.white,
          border: Border.all(
            color: _isSelected ? Colors.indigo : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          children: [
            Checkbox(
              value: _isSelected,
              onChanged: (value) {
                setState(() {
                  _isSelected = value!;
                });
              },
              activeColor: Colors.indigo,
            ),
            const SizedBox(width: 8.0),
            Text(
              widget.title,
              style: TextStyle(
                fontSize: 16,
                color: _isSelected ? Colors.indigo : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
