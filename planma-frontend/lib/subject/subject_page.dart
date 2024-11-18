import 'package:flutter/material.dart';
import 'package:planma_app/subject/create_subject.dart';
import 'package:planma_app/task/widget/search_bar.dart';
import 'package:planma_app/subject/widget/day_schedule.dart'; // Import the new file

class ClassSchedule extends StatefulWidget {
  const ClassSchedule({super.key});

  @override
  _ClassScheduleState createState() => _ClassScheduleState();
}

class _ClassScheduleState extends State<ClassSchedule> {
  bool isByDate = true;

  // List of days, which can be modified
  List<String> days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Class Schedule'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
            child: Row(
              children: [
                Expanded(child: CustomSearchBar()),
                const SizedBox(width: 10),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.filter_list, color: Colors.black),
                  onSelected: (value) {
                    setState(() {
                      isByDate = value == 'By Date';
                    });
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem<String>(
                      value: 'By Date',
                      child: Text('By Date',
                          style: TextStyle(color: Colors.black)),
                    ),
                    const PopupMenuItem<String>(
                      value: 'By Subject',
                      child: Text('By Subject',
                          style: TextStyle(color: Colors.black)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: isByDate
                ? ListView.builder(
                    itemCount: days.length,
                    itemBuilder: (context, index) {
                      return DaySchedule(
                        day: days[index],
                        isByDate: isByDate,
                      );
                    },
                  )
                : Container(), // Empty container for "By Subject" view
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddClassScreen()),
          );
        },
        backgroundColor: Color(0xFF173F70),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
