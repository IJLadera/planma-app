import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:planma_app/task/create_task.dart';
import 'package:planma_app/task/widget/search_bar.dart';
import 'by_date_view.dart';
import 'by_subject_view.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  _TasksPageState createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  bool isByDate = true;

  final tasksBySubject = {
    'Subject Code 1': [
      {
        'taskName': 'Task Name 1',
        'subject': 'Subject Code 1',
        'duration': '2 hours',
        'description': 'Description for Task 1',
        'date': '2024-01-11',
        'time': '10:00 AM - 12:00 PM',
        'deadline': '2024-01-14',
      },
    ],
    'Subject Code 2': [
      {
        'taskName': 'Task Name 2',
        'subject': 'Subject Code 2',
        'duration': '1 hour',
        'description': 'Description for Task 2',
        'date': '2024-01-12',
        'time': '01:00 PM - 02:00 PM',
        'deadline': '2024-01-16',
      },
    ],
  };

  final tasks = [
    {
      'taskName': 'Task Name 1',
      'subject': 'Subject Code 1',
      'duration': '2 hours',
      'description': 'Description for Task 1',
      'date': '2024-01-11',
      'time': '10:00 AM - 12:00 PM',
      'deadline': '2024-01-14',
    },
    {
      'taskName': 'Task Name 2',
      'subject': 'Subject Code 2',
      'duration': '1 hour',
      'description': 'Description for Task 2',
      'date': '2024-01-12',
      'time': '01:00 PM - 02:00 PM',
      'deadline': '2024-01-16',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tasks',
          style: GoogleFonts.openSans(
              fontWeight: FontWeight.bold, color: Color(0xFF173F70)),
        ),
        backgroundColor: Color(0xFFFFFFFF),
      ),
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(child: CustomSearchBar()),
                const SizedBox(width: 8),
                PopupMenuButton(
                  icon: const Icon(Icons.filter_list, color: Colors.black),
                  onSelected: (value) {
                    setState(() {
                      isByDate = value == 'By Date';
                    });
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'By Date',
                      child: Text(
                        'By date',
                        style: GoogleFonts.openSans(color: Colors.black),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'By Subject',
                      child: Text(
                        'By subject',
                        style: GoogleFonts.openSans(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: isByDate
                ? ByDateView(tasks: tasks)
                : BySubjectView(tasksBySubject: tasksBySubject),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTaskScreen()),
          );
        },
        backgroundColor: const Color(0xFF173F70),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
