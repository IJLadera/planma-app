import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:planma_app/Providers/attended_class_provider.dart';
import 'package:planma_app/models/attended_class_model.dart';
import 'package:planma_app/models/class_schedules_model.dart';
import 'package:planma_app/subject/widget/subject_detail_row.dart';
import 'package:planma_app/subject/widget/widget.dart';
import 'package:provider/provider.dart';

class ClassAttendanceHistoryScreen extends StatefulWidget {
  final ClassSchedule classSchedule;
  final List<AttendedClass> attendedClasses;
  final String selectedAttendance;
  final bool isTodayClassDay;

  const ClassAttendanceHistoryScreen({
    super.key,
    required this.classSchedule,
    required this.attendedClasses,
    required this.selectedAttendance,
    required this.isTodayClassDay,
  });

  @override
  _ClassAttendanceHistoryScreenState createState() =>
      _ClassAttendanceHistoryScreenState();
}

class _ClassAttendanceHistoryScreenState
    extends State<ClassAttendanceHistoryScreen> {
  String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  late List<AttendedClass> pastRecords;
  late String selectedAttendance;

  @override
  void initState() {
    super.initState();

    selectedAttendance = widget.selectedAttendance;

    // Get past attendance records (excluding today)
    pastRecords = widget.attendedClasses
        .where((record) => record.attendanceDate != todayDate)
        .toList();
  }

  // Handle attendance functionality
  void _handleAttendanceChange(String? newValue, String attendanceDate) async {
    if (newValue != null) {
      final attendanceProvider =
          Provider.of<AttendedClassProvider>(context, listen: false);

      final isToday = attendanceDate == todayDate;

      if (isToday) {
        setState(() {
          selectedAttendance = newValue;
        });
      }

      try {
        DateTime targetDate = DateTime.parse(attendanceDate);

        if (isToday) {
          final existingAttendance = CustomWidgets.getTodaysAttendance(
              attendanceProvider.attendedClasses, widget.classSchedule);
          if (existingAttendance != null && existingAttendance.id != -1) {
            targetDate = DateTime.parse(existingAttendance.attendanceDate);
          }
        }

        await attendanceProvider.markAttendance(
          classScheduleId: widget.classSchedule.classschedId!,
          attendedDate: targetDate,
          status: newValue,
        );

        // Update attendance status display for past records

        if (!isToday) {
          setState(() {
            final recordIndex = pastRecords.indexWhere(
                (record) => record.attendanceDate == attendanceDate);
            if (recordIndex != -1) {
              pastRecords[recordIndex] =
                  pastRecords[recordIndex].copyWith(status: newValue);
            }
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Attendance marked as $newValue',
              style: GoogleFonts.openSans(fontSize: 14),
            ),
          ),
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to update attendance: $error',
              style: GoogleFonts.openSans(fontSize: 14),
            ),
          ),
        );
      }
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
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, selectedAttendance);
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context, selectedAttendance);
            },
          ),
          title: Text(
            "Class Attendance",
            style: GoogleFonts.openSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF173F70),
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Class Summary Section
              Text(
                "Class Summary",
                style: GoogleFonts.openSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF173F70)),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFFFFBB70),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SubjectDetailRow(
                        title: "Code:",
                        detail: widget.classSchedule.subjectCode),
                    SubjectDetailRow(
                        title: "Title:",
                        detail: widget.classSchedule.subjectTitle),
                    SubjectDetailRow(
                        title: "Day:", detail: widget.classSchedule.dayOfWeek),
                    SubjectDetailRow(
                        title: "Time:",
                        detail:
                            "${_formatTimeForDisplay(widget.classSchedule.scheduledStartTime)} - ${_formatTimeForDisplay(widget.classSchedule.scheduledEndTime)}"),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.isTodayClassDay) ...[
                    Text(
                      "Today",
                      style: GoogleFonts.openSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF173F70),
                      ),
                    ),
                    const SizedBox(height: 10),
                    CustomWidgets.buildAttendanceItemDropdown(
                      date: todayDate,
                      value: selectedAttendance,
                      onChanged: (newValue) =>
                          _handleAttendanceChange(newValue, todayDate),
                    ),
                    const SizedBox(height: 20),
                  ],
                  if (pastRecords.isNotEmpty) ...[
                    Text(
                      "Past",
                      style: GoogleFonts.openSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF173F70),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...pastRecords.map(
                        (record) => CustomWidgets.buildAttendanceItemDropdown(
                              date: record.attendanceDate,
                              value: record.status,
                              onChanged: (newValue) => _handleAttendanceChange(
                                  newValue, record.attendanceDate),
                            )),
                  ] else if (!widget.isTodayClassDay) ...[
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Text(
                          "No attendance records available.",
                          style: GoogleFonts.openSans(
                            fontSize: 14,
                            color: Color(0xFF173F70),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
