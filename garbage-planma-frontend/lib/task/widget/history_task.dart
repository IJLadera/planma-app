import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:planma_app/Providers/task_provider.dart';
import 'package:planma_app/task/view_task.dart';
import 'package:provider/provider.dart';

class HistoryTaskScreen extends StatefulWidget {
  const HistoryTaskScreen({super.key});

  @override
  State<HistoryTaskScreen> createState() => _HistoryTaskScreenState();
}

class _HistoryTaskScreenState extends State<HistoryTaskScreen> {
  @override
  void initState() {
    super.initState();
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    // Automatically fetch tasks when screen loads
    taskProvider.fetchCompletedTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(builder: (context, taskProvider, child) {
      final tasks = taskProvider.completedTasks;

      return Scaffold(
        appBar: AppBar(
          title: Text(
            'History',
            style: GoogleFonts.openSans(
              fontWeight: FontWeight.bold,
              color: Color(0xFF173F70),
            ),
          ),
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Color(0xFF173F70)),
        ),
        body: tasks.isEmpty
              ? Center(
                  child: Text(
                    'No completed tasks yet.',
                    style: GoogleFonts.openSans(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    final formattedDate = DateFormat('dd MMMM yyyy')
                        .format(task.scheduledDate)
                        .toString();
                    return Card(
                      margin: const EdgeInsets.all(10),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.blueAccent,
                          child: Icon(
                            Icons.event,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          task.taskName,
                          style: GoogleFonts.openSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          'Task Date: $formattedDate',
                          style: GoogleFonts.openSans(color: Colors.grey),
                        ),
                        trailing: Icon(Icons.chevron_right, color: Colors.grey),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  TaskDetailScreen(task: task),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
      );
    });
  }
}
