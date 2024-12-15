import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:planma_app/Providers/task_provider.dart';
import 'package:planma_app/task/create_task.dart';
import 'package:planma_app/task/widget/search_bar.dart';
import 'package:provider/provider.dart';
import 'by_date_view.dart';
import 'by_subject_view.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  _TasksPageState createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  bool isByDate = true;

  @override
  void initState() {
    super.initState();
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    // Automatically fetch tasks when screen loads
    taskProvider.fetchTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(builder: (context, taskProvider, child) {
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
                          'By Date',
                          style: GoogleFonts.openSans(color: Colors.black),
                        ),
                      ),
                      PopupMenuItem(
                        value: 'By Subject',
                        child: Text(
                          'By Subject',
                          style: GoogleFonts.openSans(color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: taskProvider.tasks.isEmpty
                ? Center(
                  child: Text(
                    'No tasks added yet',
                    style: GoogleFonts.openSans(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                )
              : isByDate
                ? ByDateView(tasksView: taskProvider.tasks)
                : BySubjectView(tasksView: taskProvider.tasks),
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
    });
  }
}
