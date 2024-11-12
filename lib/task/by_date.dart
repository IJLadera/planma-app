import 'package:flutter/material.dart';
import 'package:planma_app/task/widget/task_item.dart'; // Ensure this path is correct
import 'package:planma_app/task/widget/search_bar.dart'; // Import the SearchBar widget
import 'package:planma_app/task/widget/task_section.dart'; // Import the TaskSection widget
import 'package:planma_app/task/widget/filter_dialog.dart';

class ByDate extends StatefulWidget {
  @override
  _ByDate createState() => _ByDate();
}

class _ByDate extends State<ByDate> {
  String selectedFilter = 'None';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tasks"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Custom Search Bar
                  Expanded(
                    child: CustomSearchBar(),
                  ),
                  SizedBox(
                      width: 16), // Space between search bar and filter button
                  // Filter Button
                  IconButton(
                    icon: Icon(Icons.filter_alt),
                    onPressed: () {
                      // Open the filter dialog
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return FilterDialog(
                            onFilterSelected: (filter) {
                              setState(() {
                                selectedFilter = filter;
                              });
                            },
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            // Task sections for each date
            TaskSection(title: 'Today', tasks: [
              TaskItem(
                taskName: "Task 1",
                subject: "Subject A",
                duration: "2 hrs",
                icon: Icons.flag,
                priority: 'High', // Priority
              ),
              TaskItem(
                taskName: "Task 2",
                subject: "Subject B",
                duration: "1 hr",
                icon: Icons.flag,
                priority: 'Low', // Priority
              ),
              TaskItem(
                taskName: "Task 3",
                subject: "Subject C",
                duration: "3 hrs",
                icon: Icons.flag,
                priority: 'Medium', // Priority
              ),
            ]),
            TaskSection(title: 'Tomorrow', tasks: [
              TaskItem(
                taskName: "Task 4",
                subject: "Subject D",
                duration: "4 hrs",
                icon: Icons.flag,
                priority: 'High', // Priority
              ),
            ]),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: FloatingActionButton(
          onPressed: () {
            // Add task creation logic here
          },
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}
