import 'package:flutter/material.dart';
import 'package:planma_app/subject/edit_subject.dart';
import 'package:planma_app/subject/widget/subject_detail_row.dart';

class SubjectDetailScreen extends StatefulWidget {
  final Map<String, dynamic> subject;

  const SubjectDetailScreen({Key? key, required this.subject})
      : super(key: key);

  @override
  _SubjectDetailScreenState createState() => _SubjectDetailScreenState();
}

class _SubjectDetailScreenState extends State<SubjectDetailScreen> {
  String selectedAttendance = 'Did Not Attend';

  // Function to determine color based on the selected value
  Color getColor(String value) {
    switch (value) {
      case 'Did Not Attend':
        return Colors.red;
      case 'Excused':
        return Colors.blue;
      case 'Attended':
        return Colors.green;
      default:
        return Colors.grey; // Default for unselected
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.blue),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
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
            icon: const Icon(Icons.delete, color: Colors.blue),
            onPressed: () {
              // Handle delete action
            },
          ),
        ],
        title: const Text(
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
                SubjectDetailRow(
                    title: 'Title:', detail: widget.subject['name']),
                SubjectDetailRow(
                    title: 'Code:', detail: widget.subject['code']),
                SubjectDetailRow(
                    title: 'Time:', detail: widget.subject['time']),
                SubjectDetailRow(
                    title: 'Room:', detail: widget.subject['room'] ?? 'N/A'),
                const SizedBox(height: 20),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: getColor(selectedAttendance),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    value: selectedAttendance,
                    icon: const Icon(Icons.arrow_drop_down),
                    isExpanded: true,
                    underline: const SizedBox(), // Remove default underline
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedAttendance = newValue!;
                      });
                    },
                    items: <String>['Did Not Attend', 'Excused', 'Attended']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                value,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: value == selectedAttendance
                                      ? getColor(value)
                                      : Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
