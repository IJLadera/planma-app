import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:planma_app/reports/widget/bottom_sheet.dart';
import 'package:planma_app/reports/widget/class.dart';
import 'package:planma_app/reports/widget/charts.dart'; // Import the new charts file

class ReportsPage extends StatefulWidget {
  const ReportsPage({Key? key}) : super(key: key);

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  String selectedCategory = 'Task'; // Default category
  String selectedTimeFilter = 'Day'; // Default filter
  String formattedTimeFilter = '';
  DateTime selectedDate = DateTime.now();
  bool isLoading = true;

  // Placeholder task
  List<TaskTimeSpent> taskTimeSpent = [];
  List<FinishedTask> taskFinished = [];
  List<TaskTimeDistribution> taskTimeDistribution = [];
  // Placeholder event
  List<EventAttendancecSummary> eventAttendanceSummary = [];
  List<EventTypeDistribution> eventTypeDistribution = [];
  List<EventAttendanceDistribution> eventAttendanceDistribution = [];
  //Placeholder class schedules
  List<ClassAttendanceSummary> classAttendanceSummary = [];
  List<ClassAttendanceDistribution> classAttendanceDistribution = [];
  //Placeholder activities
  List<ActivitiesTimeSpent> activitiesTimeSpent = [];
  List<ActivitiesDone> activitiesDone = [];
  //Placeholder goals
  List<GoalTimeSpent> goalTimeSpent = [];
  //Placeholder sleep
  List<SleepDuration> sleepDuration = [];

  @override
  void initState() {
    super.initState();
    _updateFormattedTimeFilter();
    _fetchChartData();
  }

  void _updateFormattedTimeFilter() {
    DateTime today = DateTime.now();
    DateTime startOfWeek =
        today.subtract(Duration(days: today.weekday - 1)); // Start of the week
    DateTime endOfWeek =
        startOfWeek.add(const Duration(days: 6)); // End of the week

    switch (selectedTimeFilter) {
      case 'Week':
        formattedTimeFilter =
            '${DateFormat('yyyy-MM-dd').format(startOfWeek)} - ${DateFormat('yyyy-MM-dd').format(endOfWeek)}';
        selectedDate = startOfWeek;
        break;
      case 'Month':
        formattedTimeFilter = DateFormat('MMMM').format(today);
        selectedDate = today;
      case 'Year':
      
      case 'Semester':
        formattedTimeFilter =
            DateFormat(selectedTimeFilter == 'Semester' ? 'MMMM yyyy' : 'yyyy')
                .format(today);
        selectedDate = today;
        break;
      case 'Day':
      default:
        formattedTimeFilter = DateFormat('yyyy-MM-dd').format(today);
        selectedDate = today;
        break;
    }
  }

  Future<void> _fetchChartData() async {
    await Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        // Example data for tasks
        taskTimeSpent = [
          TaskTimeSpent('Sun', 10),
          TaskTimeSpent('Mon', 30),
          TaskTimeSpent('Tue', 20),
          TaskTimeSpent('Wed', 40),
          TaskTimeSpent('Thu', 25),
          TaskTimeSpent('Fri', 35),
          TaskTimeSpent('Sat', 15),
        ];

        taskTimeDistribution = [
          TaskTimeDistribution('Subject Code 1', 40, Color(0xFFFF495F)),
          TaskTimeDistribution('Subject Code 2', 40, Color(0xFF3A82EF)),
          TaskTimeDistribution('Subject Code 3', 40, Color(0xFF5EE173)),
          TaskTimeDistribution('Subject Code 4', 40, Color(0xFFFFB038)),
          TaskTimeDistribution('Subject Code 5', 40, Color(0xFFEE3CD2)),
        ];

        taskFinished = [
          FinishedTask('IT311', 4),
          FinishedTask('IT312', 2),
          FinishedTask('IT313', 4),
          FinishedTask('IT314', 1),
          FinishedTask('IT315', 6),
        ];

        // Example data for events
        eventAttendanceSummary = [
          EventAttendancecSummary('Attendance', 50, Color(0xFF32C652)),
          EventAttendancecSummary('Did Not Attend', 30, Color(0xFFEF4738)),
        ];

        eventTypeDistribution = [
          EventTypeDistribution('Personal', 15, Color(0xFF00C7F2)),
          EventTypeDistribution('Academic', 25, Color(0xFFFBC62F)),
        ];

        eventAttendanceDistribution = [
          EventAttendanceDistribution(
            'Event 1',
            2.0,
            1.0,
          ),
          EventAttendanceDistribution('Event 2', 6.0, 4.0),
        ];

        // Example data for class schedules
        classAttendanceSummary = [
          ClassAttendanceSummary('Attended', 55, Color(0xFF32C652)),
          ClassAttendanceSummary('Excused', 12, Color(0xFF3A82EF)),
          ClassAttendanceSummary('Did Not Attend', 12, Color(0xFFEF4738)),
        ];

        classAttendanceDistribution = [
          ClassAttendanceDistribution('IT311', 1, 1, 2),
          ClassAttendanceDistribution('IT311', 1, 1, 2),
          ClassAttendanceDistribution('IT313', 2, 3, 0),
          ClassAttendanceDistribution('IT314', 1, 1, 1),
          ClassAttendanceDistribution('IT315', 1, 2, 2),
          ClassAttendanceDistribution('ES21a', 0, 0, 3),
        ];

        // Example data for activities
        activitiesTimeSpent = [
          ActivitiesTimeSpent('Sun', 0),
          ActivitiesTimeSpent('Mon', 20),
          ActivitiesTimeSpent('Tue', 10),
          ActivitiesTimeSpent('Wed', 0),
          ActivitiesTimeSpent('Thu', 40),
          ActivitiesTimeSpent('Fri', 30),
          ActivitiesTimeSpent('Sat', 0),
        ];

        activitiesDone = [
          ActivitiesDone('Sun', 1),
          ActivitiesDone('Mon', 4),
          ActivitiesDone('Tue', 2),
          ActivitiesDone('Wed', 1),
          ActivitiesDone('Thu', 6),
          ActivitiesDone('Fri', 3),
          ActivitiesDone('Sat', 1),
        ];

        // Example data for goals

        goalTimeSpent = [
          GoalTimeSpent('Sun', 3),
          GoalTimeSpent('Mon', 20),
          GoalTimeSpent('Tue', 10),
          GoalTimeSpent('Wed', 4),
          GoalTimeSpent('Thu', 30),
          GoalTimeSpent('Fri', 21),
          GoalTimeSpent('Sat', 2),
        ];

        // Example data for sleep

        sleepDuration = [
          SleepDuration('Sun', 0),
          SleepDuration('Mon', 4),
          SleepDuration('Tue', 2),
          SleepDuration('Wed', 6),
          SleepDuration('Thu', 4),
          SleepDuration('Fri', 4),
          SleepDuration('Sat', 0),
        ];
        isLoading = false;
      });
    });
  }

  void _onTimeFilterSelected(String filter) {
    setState(() {
      selectedTimeFilter = filter;
      _updateFormattedTimeFilter();
      isLoading = true;
    });
    _fetchChartData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        leading: const BackButton(),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Sticky header: Bottom sheet buttons and time filter
          Container(
            color: Colors.white,
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              children: [
                // Bottom sheet button
                GestureDetector(
                  onTap: () {
                    BottomSheetWidget.show(
                      context,
                      onCategorySelected: (category) {
                        setState(() {
                          selectedCategory =
                              category; // Update selected category
                        });
                      },
                      initialSelection: selectedCategory,
                    );
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(40.0),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          selectedCategory,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Icon(Icons.arrow_drop_down,
                            color: Colors.grey.shade600),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                // Time filter buttons
                ToggleButtonsDemo(
                  labels: ['Day', 'Week', 'Month', 'Semester', 'Year'],
                  onSelected: _onTimeFilterSelected,
                ),
                const SizedBox(height: 8.0),
                // Display the selected time range
                Center(
                  child: Text(
                    formattedTimeFilter.isNotEmpty
                        ? 'Selected Date/Range: $formattedTimeFilter'
                        : 'No date/range selected',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Scrollable charts
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // TASKS category
                    if (selectedCategory == 'Task') ...[
                      TaskCharts(
                        isLoading: isLoading,
                        taskTimeSpent: taskTimeSpent,
                        taskTimeDistribution: taskTimeDistribution,
                        taskFinished: taskFinished,
                      ),
                    ],
                    // EVENTS category
                    if (selectedCategory == 'Event') ...[
                      EventCharts(
                        isLoading: isLoading,
                        eventAttendanceSummary: eventAttendanceSummary,
                        eventTypeDistribution: eventTypeDistribution,
                        eventAttendanceDistribution:
                            eventAttendanceDistribution,
                      ),
                    ],
                    if (selectedCategory == 'Class Schedules') ...[
                      ClassScheduleCharts(
                        isLoading: isLoading,
                        classAttendanceSummary: classAttendanceSummary,
                        classAttendanceDistribution:
                            classAttendanceDistribution,
                      ),
                    ],
                    if (selectedCategory == 'Activities') ...[
                      ActivitiesChart(
                        isLoading: isLoading,
                        activitiesTimeSpent: activitiesTimeSpent,
                        activitiesDone: activitiesDone,
                      ),
                    ],
                    if (selectedCategory == 'Goals') ...[
                      GoalsCharts(
                        isLoading: isLoading,
                        goalTimeSpent: goalTimeSpent,
                      ),
                    ],
                    if (selectedCategory == 'Sleep') ...[
                      SleepCharts(
                        isLoading: isLoading,
                        sleepDuration: sleepDuration,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
