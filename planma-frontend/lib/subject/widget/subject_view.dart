import 'package:flutter/material.dart';
import 'package:planma_app/subject/edit_subject.dart';
import 'package:planma_app/subject/widget/subject_detail_row.dart';

class SubjectDetailScreen extends StatelessWidget {
  final Map<String, dynamic> subject;

  SubjectDetailScreen({required this.subject});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.close, color: Colors.blue),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditClass(),
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.blue),
              onPressed: () {
                //
              },
            ),
          ],
          title: Text(
            'Subject',
            style: TextStyle(
                color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(9),
              color: Colors.grey[100],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SubjectDetailRow(title: 'Title:', detail: subject['name']),
                  SubjectDetailRow(title: 'Code:', detail: subject['code']),
                  SubjectDetailRow(title: 'Time:', detail: subject['time']),
                  SubjectDetailRow(title: 'Room:', detail: subject['room'] ?? 'N/A'),
                ],
              ),
            ),
          ),
        ));
  }
}
