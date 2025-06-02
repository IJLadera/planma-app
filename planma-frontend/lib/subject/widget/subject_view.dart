import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:planma_app/Providers/class_schedule_provider.dart';
import 'package:planma_app/Providers/semester_provider.dart';
import 'package:planma_app/subject/edit_subject.dart';
import 'package:planma_app/subject/widget/attendance_history.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final semesterProvider =
          Provider.of<SemesterProvider>(context, listen: false);
      _fetchSemesterDetails(semesterProvider);
    });
  }

  Future<void> _fetchSemesterDetails(SemesterProvider semesterProvider) async {
    print('Fetching semester with ID: ${widget.classSchedule.semesterId}');
    try {
      final semester = await semesterProvider
          .getSemesterDetails(widget.classSchedule.semesterId);
      print(semester);
      if (!mounted) return;
      setState(() {
        semesterDetails =
            "${semester?['acad_year_start']} - ${semester?['acad_year_end']} ${semester?['semester']}";
      });
    } catch (e) {
      if (!mounted) return;
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
        title: Text(
          'Delete Subject',
          style: GoogleFonts.openSans(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
        ),
        content: Text(
          'Are you sure you want to delete this subject?',
          style: GoogleFonts.openSans(
            fontSize: 16,
            color: Color(0xFF1D4E89),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.openSans(
                fontSize: 16,
                color: Color(0xFF1D4E89),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(
              'Delete',
              style:
                  GoogleFonts.openSans(fontSize: 16, color: Color(0xFF1D4E89)),
            ),
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
              schedule.classschedId == widget.classSchedule.classschedId);

      final startTime = _formatTimeForDisplay(schedule.scheduledStartTime);
      final endTime = _formatTimeForDisplay(schedule.scheduledEndTime);
      String currentDay = DateFormat('EEEE').format(DateTime.now());
      bool isTodayClassDay = currentDay == schedule.dayOfWeek;

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
                  const SizedBox(height: 30),
                  if (isTodayClassDay) ...[
                    Center(
                      child: Text(
                        "Today's Attendance",
                        style: GoogleFonts.openSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF173F70)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    CustomWidgets.dropwDownForAttendance(
                      label: 'Attendance',
                      value: selectedAttendance,
                      items: ['Did Not Attend', 'Excused', 'Attended'],
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            selectedAttendance = newValue;
                          });
                        }
                      },
                      backgroundColor: Color(0XFFF5F5F5),
                      labelColor: Colors.black,
                      textColor: CustomWidgets.getColor(selectedAttendance),
                      borderRadius: 8.0,
                      fontSize: 14.0,
                    ),
                  ],
                  const SizedBox(height: 20),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ClassAttendanceHistoryScreen(
                                    classSchedule: widget.classSchedule,
                                    attendanceRecords: [
                                      {
                                        "date": "08 February 2025",
                                        "status": selectedAttendance
                                      },
                                      {
                                        "date": "05 February 2025",
                                        "status": "Attended"
                                      },
                                      {
                                        "date": "04 February 2025",
                                        "status": "Excused"
                                      },
                                    ],
                                  )),
                        );
                      },
                      child: Text(
                        "See Attendance History",
                        style: GoogleFonts.openSans(
                          fontSize: 14,
                          color: Color(0xFF173F70),
                          decoration:
                              TextDecoration.underline, // Adds underline
                        ),
                      ),
                    ),
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
