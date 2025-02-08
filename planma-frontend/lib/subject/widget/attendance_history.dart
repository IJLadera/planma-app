import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:planma_app/models/class_schedules_model.dart';
import 'package:planma_app/subject/widget/subject_detail_row.dart';
import 'package:planma_app/subject/widget/widget.dart';

class ClassAttendanceHistoryScreen extends StatefulWidget {
  final ClassSchedule classSchedule;
  final List<Map<String, String>> attendanceRecords;

  const ClassAttendanceHistoryScreen({
    Key? key,
    required this.classSchedule,
    required this.attendanceRecords,
  }) : super(key: key);

  @override
  _ClassAttendanceHistoryScreenState createState() =>
      _ClassAttendanceHistoryScreenState();
}

class _ClassAttendanceHistoryScreenState
    extends State<ClassAttendanceHistoryScreen> {
  String todayDate = DateFormat('dd MMMM yyyy').format(DateTime.now());
  Map<String, String>? todayRecord;
  late List<Map<String, String>> pastRecords;
  late String selectedAttendance;

  @override
  void initState() {
    super.initState();

    // Find today's record or set to null if not found
    todayRecord = widget.attendanceRecords.firstWhere(
      (record) => record["date"] == todayDate,
      orElse: () => <String, String>{}, // Returns an empty Map instead of null
    );

    // Set initial value for the dropdown if today's record exists
    selectedAttendance = todayRecord?["status"] ?? "Did Not Attend";

    // Get past attendance records (excluding today)
    pastRecords = widget.attendanceRecords
        .where((record) => record["date"] != todayDate)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Class Summary Section
            Text(
              "Class Summary",
              style: GoogleFonts.openSans(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
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
                      title: "Code:", detail: widget.classSchedule.subjectCode),
                  SubjectDetailRow(
                      title: "Title:",
                      detail: widget.classSchedule.subjectTitle),
                  SubjectDetailRow(
                      title: "Day:", detail: widget.classSchedule.dayOfWeek),
                  SubjectDetailRow(
                      title: "Time:",
                      detail:
                          "${widget.classSchedule.scheduledStartTime} - ${widget.classSchedule.scheduledEndTime}"),
                ],
              ),
            ),
            const SizedBox(height: 20),

            if (todayRecord != null) ...[
              Text(
                "Today",
                style: GoogleFonts.openSans(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              CustomWidgets.buildAttendanceItemDropdown(
                todayRecord!["date"]!,
                todayRecord!["status"]!,
                onChanged: (String? newValue) {
                  setState(() {
                    todayRecord!["status"] = newValue!;
                  });
                },
              ),
              const SizedBox(height: 20),
            ],

// Past Attendance
            Text(
              "Past",
              style: GoogleFonts.openSans(
                  fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Column(
              children: pastRecords.isNotEmpty
                  ? pastRecords
                      .map((record) => CustomWidgets.buildAttendanceItem(
                            record["date"]!,
                            record["status"]!,
                          ))
                      .toList()
                  : [
                      Text(
                        "No past records available.",
                        style: GoogleFonts.openSans(fontSize: 14),
                      ),
                    ],
            ),
          ],
        ),
      ),
    );
  }
}
