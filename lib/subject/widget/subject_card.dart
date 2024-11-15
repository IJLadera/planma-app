import 'package:flutter/material.dart';

class SubjectCard extends StatelessWidget {
  final bool isByDate;

  // Constructor to accept the isByDate parameter
  SubjectCard({required this.isByDate});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        color: Colors.orange[100],
        child: ListTile(
          title: Text('Subject Code',
              style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: isByDate
              ? Text('Subject')
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Subject'),
                    Text('Free Period'),
                  ],
                ),
        ),
      ),
    );
  }
}
