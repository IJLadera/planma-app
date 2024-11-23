import 'package:flutter/material.dart';
import 'package:planma_app/subject/create_subject.dart';
import 'package:planma_app/subject/widget/add_semester.dart';
import 'package:planma_app/subject/widget/day_schedule.dart';
import 'package:planma_app/subject/widget/widget.dart'; // Assuming this contains `CustomWidgets`

class ClassSchedule extends StatefulWidget {
  const ClassSchedule({Key? key}) : super(key: key);

  @override
  _ClassScheduleState createState() => _ClassScheduleState();
}

class _ClassScheduleState extends State<ClassSchedule> {
  bool isByDate = true;

  // List of days
  final List<String> days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday'
  ];

  // Dummy data for subjects
  final List<Map<String, String>> subjects = [
    {'name': 'Math 101', 'schedule': 'Monday 10:00 AM - 12:00 PM'},
    {'name': 'Physics 202', 'schedule': 'Wednesday 1:00 PM - 3:00 PM'},
    {'name': 'English 303', 'schedule': 'Friday 8:00 AM - 10:00 AM'},
  ];

  // List of semesters
  final List<String> semesters = [
    '2024-2025 1st Semester',
    '2024-2025 2nd Semester',
    '- Add Semester -'
  ];

  // Selected semester
  String selectedSemester = '2024-2025 1st Semester';

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
                Expanded(
                  child: CustomWidgets.buildDropdownField(
                    label: 'Semester',
                    value: selectedSemester,
                    items: semesters,
                    onChanged: (String? value) {
                      setState(() {
                        if (value == '- Add Semester -') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddSemesterScreen(),
                            ),
                          );
                        } else if (value != null) {
                          selectedSemester = value;
                        }
                      });
                    },
                    backgroundColor: const Color(0xFFF5F5F5),
                    labelColor: Colors.black,
                    textColor: Colors.black,
                    borderRadius: 30.0,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    fontSize: 14.0,
                  ),
                ),
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
                : ListView.builder(
                    itemCount: subjects.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: ListTile(
                          title: Text(subjects[index]['name']!),
                          subtitle: Text(subjects[index]['schedule']!),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddClassScreen()),
          );
        },
        backgroundColor: const Color(0xFF173F70),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
