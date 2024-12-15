import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:planma_app/Providers/class_schedule_provider.dart';
import 'package:planma_app/Providers/semester_provider.dart';
import 'package:planma_app/subject/edit_subject.dart';
import 'package:planma_app/subject/widget/subject_detail_row.dart';
import 'package:planma_app/models/class_schedules_model.dart';
import 'package:planma_app/subject/widget/widget.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class SubjectDetailScreen extends StatefulWidget {
  final ClassSchedule classSchedule;

  SubjectDetailScreen({
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
      final semester = await semesterProvider
          .getSemesterDetails(widget.classSchedule.semesterId);
      print(semester);
      setState(() {
        semesterDetails =
            "${semester?['acad_year_start']} - ${semester?['acad_year_end']} ${semester?['semester']}";
      });
    } catch (e) {
      setState(() {
        semesterDetails = 'Error fetching semester details';
      });
    }
  }

  // Handle delete functionality (stub for now)
  void _handleDelete(BuildContext context) async {
    final provider = Provider.of<ClassScheduleProvider>(context, listen: false);
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
            child: const Text('Delete',
                style: TextStyle(color: Color(0xFFEF4738))),
          ),
        ],
      ),
    );

    if (isConfirmed == true) {
      provider.deleteClassSchedule(widget.classSchedule.classschedId!);
      Navigator.pop(context); // Go back after deletion
    }
  }

  String _formatTimeForDisplay(String time24) {
    final timeParts = time24.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    final timeOfDay = TimeOfDay(hour: hour, minute: minute);

    // Format to "H:mm a"
    final now = DateTime.now();
    final dateTime = DateTime(
      now.year,
      now.month,
      now.day,
      timeOfDay.hour,
      timeOfDay.minute,
    );
    return DateFormat.jm().format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ClassScheduleProvider>(
        builder: (context, classScheduleProvider, child) {
      final schedule = classScheduleProvider.classSchedules.firstWhere(
        (schedule) =>
            schedule.classschedId == widget.classSchedule.classschedId,
        orElse: () => ClassSchedule(
          classschedId: -1, // Indicate an invalid or default ID
          subjectCode: 'N/A',
          subjectTitle: 'No Title',
          semesterId: 0,
          dayOfWeek: 'N/A',
          scheduledStartTime: '00:00',
          scheduledEndTime: '00:00',
          room: 'No Room',
        ),
      );

      // Check if the returned schedule is the default one
      if (schedule.classschedId == -1) {
        return Scaffold(
          appBar: AppBar(title: Text('Subject Details')),
          body: Center(child: Text('Schedule not found')),
        );
      }

      final startTime = _formatTimeForDisplay(schedule.scheduledStartTime);
      final endTime = _formatTimeForDisplay(schedule.scheduledEndTime);

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
              icon: const Icon(Icons.edit, color: Color(0xFF173F70)),
              onPressed: () async {
                await Navigator.push<ClassSchedule>(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        EditClass(classSchedule: widget.classSchedule),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Color(0xFF173F70)),
              onPressed: () => _handleDelete(context),
            ),
          ],
          centerTitle: true,
          title: Text(
            'Subject',
            style: GoogleFonts.openSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF173F70),
            ),
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
                      title: 'Code:', detail: schedule.subjectCode),
                  const Divider(),
                  SubjectDetailRow(
                      title: 'Title:', detail: schedule.subjectTitle),
                  const Divider(),
                  SubjectDetailRow(title: 'Semester:', detail: semesterDetails),
                  const Divider(),
                  SubjectDetailRow(title: 'Day:', detail: schedule.dayOfWeek),
                  const Divider(),
                  SubjectDetailRow(
                      title: 'Time:', detail: '$startTime - $endTime'),
                  const Divider(),
                  SubjectDetailRow(
                      title: 'Room:',
                      detail: schedule.room.isNotEmpty ? schedule.room : 'N/A'),
                  const Divider(),
                  const SizedBox(height: 20),
                  CustomWidgets.dropwDownForAttendance(
                    label: 'Attendance',
                    value: selectedAttendance,
                    items: ['Did Not Attend', 'Excused', 'Attended'],
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedAttendance = newValue; // Update the value
                        });
                      }
                    },
                    backgroundColor: Color(0XFFF5F5F5),
                    labelColor: Colors.black,
                    textColor: CustomWidgets.getColor(
                        selectedAttendance), // Use getColor as a static method
                    borderRadius: 8.0,
                    fontSize: 14.0,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
