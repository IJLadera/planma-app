import 'package:flutter/material.dart';
import 'package:planma_app/task/create_task.dart';
import 'by_date_view.dart'; // Import your ByDateView widget
import 'by_subject_view.dart'; // Import your BySubjectView widget

class TasksPage extends StatefulWidget {
  @override
  _TasksPageState createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  bool isByDate = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          PopupMenuButton(
            icon: Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                color: Colors.blue[50],
              ),
              child: Icon(Icons.filter_list, color: Colors.black),
            ),
            onSelected: (value) {
              setState(() {
                isByDate = value == 'By Date';
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'By Date',
                child: Text('By date', style: TextStyle(color: Colors.black)),
              ),
              PopupMenuItem(
                value: 'By Subject',
                child:
                    Text('By subject', style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            // Use ByDateView or BySubjectView based on the isByDate variable
            child: isByDate ? ByDateView() : BySubjectView(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateTask()),
          );
        },
        backgroundColor: Colors.blue, 
        
        child: Icon(Icons.add, color: Colors.white),
        shape: CircleBorder(),
      ),
    );
  }
}
