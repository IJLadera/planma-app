import 'package:flutter/material.dart';
import 'package:planma_app/goals/widget/goal_detail_row.dart';

class ViewGoal extends StatelessWidget {
  final String goalName;
  final int targetHours;
  final double progress;

  const ViewGoal({
    Key? key,
    required this.goalName,
    required this.targetHours,
    required this.progress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.blue),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: Colors.blue),
            onPressed: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => EditTask()),
              // );
            },
          ),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.blue),
            onPressed: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => deleteTask()),
              // );
            },
          ),
        ],
        centerTitle: true,
        title: Text(
          'Task',
          style: TextStyle(
              color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8), color: Colors.grey[100]),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GoalDetailPage()
              ],
            ),
          ),
        ),
      ),
    );
  }
}
