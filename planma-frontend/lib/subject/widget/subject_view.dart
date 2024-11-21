import 'package:flutter/material.dart';
import 'package:planma_app/subject/edit_subject.dart';
import 'package:planma_app/subject/widget/subject_detail_row.dart';

class SubjectDetailScreen extends StatefulWidget {
  final String subject_code;
  final String subject_title;
  final String semester;
  final String start_time;
  final String end_time;
  final String room;
  final String selected_days;

  const SubjectDetailScreen({
    Key? key,
    required this.subject_code,
    required this.subject_title,
    required this.semester,
    required this.start_time,
    required this.end_time,
    required this.room,
    required this.selected_days,
  }) : super(key: key);

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

  // Handle delete functionality (stub for now)
  void _handleDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Subject'),
        content: Text('Are you sure you want to delete this subject?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Add delete functionality here
              Navigator.pop(context);
              Navigator.pop(context); // Go back after deletion
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
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
            onPressed: _handleDelete,
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
                  title: 'Code:',
                  detail: widget.subject_code, // Directly using widget.property
                ),
                SubjectDetailRow(
                  title: 'Title:',
                  detail:
                      widget.subject_title, // Directly using widget.property
                ),
                SubjectDetailRow(
                  title: 'Semester:',
                  detail: widget.semester, // Directly using widget.property
                ),
                SubjectDetailRow(
                  title: 'Day:',
                  detail:
                      widget.selected_days, // Directly using widget.property
                ),
                SubjectDetailRow(
                  title: 'Time:',
                  detail:
                      '${widget.start_time} - ${widget.end_time}', // Combining times
                ),
                SubjectDetailRow(
                  title: 'Room:',
                  detail: widget.room.isNotEmpty
                      ? widget.room
                      : 'N/A', // Handling room
                ),
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
