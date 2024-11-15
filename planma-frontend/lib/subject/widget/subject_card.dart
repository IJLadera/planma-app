import 'package:flutter/material.dart';
  import 'package:planma_app/subject/widget/subject_view.dart'; // Import the SubjectDetailScreen

class SubjectCard extends StatelessWidget {
  final bool isByDate;
  final Map<String, dynamic> subject;

  // Constructor to accept the isByDate parameter and subject data
  SubjectCard({required this.isByDate, required this.subject});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        color: Colors.orange[100],
        child: ListTile(
          title: Text(
            subject['code'], // Use the subject code from the data
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: isByDate
              ? Text(subject['name']) // Display subject name for "By Date" view
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(subject['name']), // Subject name
                    Text('Free Period'), // You can customize this detail
                  ],
                ),
          onTap: () {
            // Navigate to SubjectDetailScreen with subject data
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SubjectDetailScreen(subject: subject),
              ),
            );
          },
        ),
      ),
    );
  }
}
