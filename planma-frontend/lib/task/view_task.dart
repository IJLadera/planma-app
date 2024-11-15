import 'package:flutter/material.dart';
import 'package:planma_app/task/edit_task.dart';
import 'package:planma_app/task/widget/task_detail_row.dart';

class ViewTask extends StatelessWidget {
  final String taskName;
  final String description;
  final String date;
  final String time;
  final String deadline;
  final String subject;

  const ViewTask({
    Key? key,
    required this.taskName,
    required this.description,
    required this.date,
    required this.time,
    required this.deadline,
    required this.subject,
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditTask()),
              );
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
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[100],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TaskDetailRow(title: 'Name:', detail: taskName),
                TaskDetailRow(title: 'Description:', detail: description),
                TaskDetailRow(title: 'Date:', detail: date),
                TaskDetailRow(title: 'Time:', detail: time),
                TaskDetailRow(title: 'Deadline:', detail: deadline),
                TaskDetailRow(title: 'Subject:', detail: subject),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
