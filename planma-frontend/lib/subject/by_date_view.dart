import 'package:flutter/material.dart';
import 'package:planma_app/subject/widget/subject_view.dart';

class ByDateView extends StatelessWidget {
  final List<Map<String, dynamic>> scheduleData = [
    {
      'day': 'Monday',
      'subjects': [
        {
          'code': 'Subject Code 1',
          'name': 'Subject 1',
          'time': '9:00 AM - 10:00 AM'
        },
        {
          'code': 'Subject Code 2',
          'name': 'Subject 2',
          'time': '10:00 AM - 11:00 AM'
        },
      ],
    },
    {
      'day': 'Tuesday',
      'subjects': [
        {
          'code': 'Subject Code 3',
          'name': 'Subject 3',
          'time': '9:00 AM - 10:00 AM'
        },
      ],
    },
    {
      'day': 'Wednesday',
      'subjects': [
        {
          'code': 'Subject Code 4',
          'name': 'Subject 4',
          'time': '9:00 AM - 10:00 AM'
        },
        {
          'code': 'Subject Code 5',
          'name': 'Subject 5',
          'time': '10:00 AM - 11:00 AM'
        },
      ],
    },
    {
      'day': 'Thursday',
      'subjects': [
        {
          'code': 'Subject Code 6',
          'name': 'Subject 6',
          'time': '9:00 AM - 10:00 AM'
        },
        {
          'code': 'Subject Code 7',
          'name': 'Subject 7',
          'time': '10:00 AM - 11:00 AM'
        },
      ],
    },
    {
      'day': 'Friday',
      'subjects': [
        {
          'code': 'Subject Code 8',
          'name': 'Subject 8',
          'time': '9:00 AM - 10:00 AM'
        },
        {
          'code': 'Subject Code 9',
          'name': 'Subject 9',
          'time': '10:00 AM - 11:00 AM'
        },
      ],
    },
    {
      'day': 'Saturday',
      'subjects': [
        {
          'code': 'Subject Code 10',
          'name': 'Subject 10',
          'time': '9:00 AM - 10:00 AM'
        },
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Class Schedule'),
      ),
      body: ListView.builder(
        itemCount: scheduleData.length,
        itemBuilder: (context, index) {
          final daySchedule = scheduleData[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Day title
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  daySchedule['day'],
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              // Subjects for each day
              ...daySchedule['subjects'].map<Widget>((subject) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 4.0),
                  child: InkWell(
                    onTap: () {
                      // Navigate to SubjectDetailScreen with subject details
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SubjectDetailScreen(subject: subject),
                        ),
                      );
                    },
                    child: Card(
                      color: Colors.orange[100],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              subject['code'],
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4),
                            Text(
                              subject['name'],
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey[700]),
                            ),
                            SizedBox(height: 4),
                            Text(
                              subject['time'],
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Action to add a new schedule entry, if needed
          print("Add new subject");
        },
        backgroundColor: Colors.blue,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
