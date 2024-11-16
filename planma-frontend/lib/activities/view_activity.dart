import 'package:flutter/material.dart';
import 'package:planma_app/activities/edit_activity.dart';
import 'package:planma_app/activities/widget/activity_detail_screen.dart';

class ViewActivity extends StatelessWidget {
  final String activityName;
  final String description;
  final String date;
  final String time;

  const ViewActivity({
    Key? key,
    required this.activityName,
    required this.description,
    required this.date,
    required this.time,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.blue),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditActivity(),
                  ),
                );
              }),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.blue),
            onPressed: () {
              // Handle delete task logic
            },
          ),
        ],
        centerTitle: true,
        title: const Text(
          'Task',
          style: TextStyle(
              color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[100],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ActivityDetailsScreen(title: 'Name:', detail: activityName),
                ActivityDetailsScreen(
                    title: 'Description:', detail: description),
                ActivityDetailsScreen(title: 'Date:', detail: date),
                ActivityDetailsScreen(title: 'Time:', detail: time),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
