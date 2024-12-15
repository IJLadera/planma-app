import 'package:flutter/material.dart';
import 'package:planma_app/Providers/class_schedule_provider.dart';
import 'package:planma_app/Providers/semester_provider.dart';
import 'package:planma_app/subject/by_date_view.dart';
import 'package:planma_app/subject/by_subject_view.dart';
import 'package:planma_app/subject/create_subject.dart';
import 'package:planma_app/subject/semester/view_semester.dart';
import 'package:planma_app/subject/semester/add_semester.dart';
import 'package:planma_app/subject/widget/widget.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts

class ClassSchedule extends StatefulWidget {
  const ClassSchedule({super.key});

  @override
  _ClassScheduleState createState() => _ClassScheduleState();
}

class _ClassScheduleState extends State<ClassSchedule> {
  bool isByDate = true;

  // List of days
  final List<String> days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  // Selected semester
  String? selectedSemester;

  @override
  void initState() {
    super.initState();
    final semesterProvider =
        Provider.of<SemesterProvider>(context, listen: false);
    final classScheduleProvider =
        Provider.of<ClassScheduleProvider>(context, listen: false);

    // Fetch semesters when the screen loads
    semesterProvider.fetchSemesters().then((_) {
      if (semesterProvider.semesters.isNotEmpty) {
        // Set the default selected semester
        setState(() {
          selectedSemester =
              "${semesterProvider.semesters[0]['acad_year_start']} - ${semesterProvider.semesters[0]['acad_year_end']} ${semesterProvider.semesters[0]['semester']}";
        });

        // Automatically fetch class schedules for the default semester
        final defaultSemesterId = semesterProvider.semesters[0]['semester_id'];
        classScheduleProvider.fetchClassSchedules(
          selectedSemesterId: defaultSemesterId,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Class Schedules',
          style: GoogleFonts.openSans(
              fontWeight: FontWeight.bold, color: Color(0xFF173F70)),
        ),
        backgroundColor: Color(0xFFFFFFFF),
      ),
      body: Consumer2<SemesterProvider, ClassScheduleProvider>(
        builder: (context, semesterProvider, classScheduleProvider, child) {
          // Update semesters list
          List<String> semesters = semesterProvider.semesters
              .map((semester) =>
                  "${semester['acad_year_start']} - ${semester['acad_year_end']} ${semester['semester']}")
              .toList();
          semesters.add('- Add Semester -');

          return semesters.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Expanded(
                            child: CustomWidgets.buildDropdownField(
                              label: '- Add Semester -',
                              value: selectedSemester,
                              items: semesters,
                              onChanged: (String? value) {
                                setState(() {
                                  if (value == '- Add Semester -') {
                                    // Navigate to Add Semester screen
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            AddSemesterScreen(),
                                      ),
                                    ).then((_) {
                                      // Refresh semesters after returning
                                      semesterProvider.fetchSemesters();
                                    });
                                  } else if (value != null) {
                                    // Update the selected semester
                                    selectedSemester = value;

                                    // Parse selectedSemester to extract its components
                                    List<String> semesterParts =
                                        selectedSemester!.split(' ');
                                    int acadYearStart =
                                        int.parse(semesterParts[0]);
                                    int acadYearEnd =
                                        int.parse(semesterParts[2]);
                                    String semesterType =
                                        "${semesterParts[3]} ${semesterParts[4]}";

                                    // Find the corresponding semester_id
                                    final selectedSemesterMap =
                                        semesterProvider.semesters.firstWhere(
                                      (semester) {
                                        return semester['acad_year_start'] ==
                                                acadYearStart &&
                                            semester['acad_year_end'] ==
                                                acadYearEnd &&
                                            semester['semester'] ==
                                                semesterType;
                                      },
                                      orElse: () =>
                                          {}, // Return empty map if no match is found
                                    );

                                    if (selectedSemesterMap.isNotEmpty) {
                                      final selectedSemesterId =
                                          selectedSemesterMap['semester_id'];
                                      print(
                                          "Found semester ID: $selectedSemesterId");

                                      // Trigger fetching of class schedules using semester_id
                                      classScheduleProvider.fetchClassSchedules(
                                        selectedSemesterId: selectedSemesterId,
                                      );
                                    } else {
                                      print("No matching semester found!");
                                    }
                                  }
                                });
                              },
                              backgroundColor: const Color(0xFFF5F5F5),
                              labelColor: Colors.black,
                              textColor: Colors.black,
                              borderRadius: 30.0,
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              fontSize: 14.0,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.calendar_today,
                              size: 18.0,
                            ),
                            tooltip: 'View Semester',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const SemesterScreen()),
                              );
                            },
                          ),
                          PopupMenuButton<String>(
                            icon: const Icon(
                              Icons.filter_list,
                              color: Colors.black,
                              size: 18.0,
                            ),
                            onSelected: (value) {
                              setState(() {
                                isByDate = value == 'By Date';
                              });
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem<String>(
                                value: 'By Date',
                                child: Text(
                                  'By Date',
                                  style: GoogleFonts.openSans(
                                      color: Color(0xFF173F70), fontSize: 14),
                                ),
                              ),
                              PopupMenuItem<String>(
                                value: 'By Subject',
                                child: Text(
                                  'By Subject',
                                  style: GoogleFonts.openSans(
                                      color: Color(0xFF173F70), fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: classScheduleProvider.classSchedules.isEmpty
                          ? Center(
                              child: Text(
                                'No schedules available',
                                style: GoogleFonts.openSans(
                                  fontSize:
                                      16, // Define the font size explicitly
                                  color: Colors
                                      .black, // Customize the color as needed
                                ),
                              ),
                            )
                          : isByDate
                              ? ByDateView(
                                  days: days,
                                  subjectsView:
                                      classScheduleProvider.classSchedules,
                                )
                              : BySubjectView(
                                  subjectsView:
                                      classScheduleProvider.classSchedules,
                                ),
                    ),
                  ],
                );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddClassScreen()),
          );
        },
        backgroundColor: const Color(0xFF173F70),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
