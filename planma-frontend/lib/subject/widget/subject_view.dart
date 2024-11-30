import 'package:flutter/material.dart';
import 'package:planma_app/Providers/semester_provider.dart';
import 'package:planma_app/subject/edit_subject.dart';
import 'package:planma_app/subject/widget/subject_detail_row.dart';
import 'package:planma_app/models/class_schedules_model.dart';

class SubjectDetailScreen extends StatefulWidget {
  final ClassSchedule classSchedule;

  const SubjectDetailScreen({
    super.key,
    required this.classSchedule,
  });

  @override
  _SubjectDetailScreenState createState() => _SubjectDetailScreenState();
}

class _SubjectDetailScreenState extends State<SubjectDetailScreen> {
  String selectedAttendance = 'Did Not Attend';
  String semesterDetails = 'Loading...';
  late SemesterProvider semesterProvider;

  @override
  void initState() {
    super.initState();
    semesterProvider = SemesterProvider();
    _fetchSemesterDetails();
  }

  Future<void> _fetchSemesterDetails() async {
    print('Fetching semester with ID: ${widget.classSchedule.semesterId}');
    try {
      final semester = await semesterProvider.getSemesterDetails(widget.classSchedule.semesterId);
      print(semester);
      setState(() {
        semesterDetails = "${semester?['acad_year_start']} - ${semester?['acad_year_end']} ${semester?['semester']}";
      });
    } catch (e) {
      setState(() {
        semesterDetails = 'Error fetching semester details';
      });
    }
  }

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
  void _handleDelete() async {
    final isConfirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Subject'),
        content: const Text('Are you sure you want to delete this subject?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (isConfirmed == true) {
      // Perform deletion logic here
      Navigator.pop(context); // Go back after deletion
    }
  }

  @override
  Widget build(BuildContext context) {
    final schedule = widget.classSchedule;

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
                  detail: schedule.subjectCode, // Directly using widget.property
                ),
                SubjectDetailRow(
                  title: 'Title:',
                  detail:
                      schedule.subjectTitle, // Directly using widget.property
                ),
                SubjectDetailRow(
                  title: 'Semester:',
                  detail: semesterDetails, // Directly using widget.property
                ),
                SubjectDetailRow(
                  title: 'Day:',
                  detail:
                      schedule.dayOfWeek, // Directly using widget.property
                ),
                SubjectDetailRow(
                  title: 'Time:',
                  detail:
                      '${schedule.scheduledStartTime} - ${schedule.scheduledEndTime}', // Combining times
                ),
                SubjectDetailRow(
                  title: 'Room:',
                  detail: schedule.room.isNotEmpty
                      ? schedule.room
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
