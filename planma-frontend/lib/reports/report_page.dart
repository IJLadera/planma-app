import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:planma_app/Providers/activity_log_provider.dart';
import 'package:planma_app/Providers/attended_events_provider.dart';
import 'package:planma_app/Providers/sleep_provider.dart';
import 'package:planma_app/Providers/task_log_provider.dart';
import 'package:planma_app/models/activity_time_log_model.dart';
import 'package:planma_app/models/attended_events_model.dart';
import 'package:planma_app/models/sleep_log_model.dart';
import 'package:planma_app/models/task_time_log_model.dart';
import 'package:planma_app/reports/widget/bottom_sheet.dart';
import 'package:planma_app/reports/widget/class.dart';
import 'package:planma_app/reports/widget/charts.dart'; // Import the new charts file
import 'package:google_fonts/google_fonts.dart';
import 'package:planma_app/reports/widget/fetch_data.dart';
import 'package:provider/provider.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  String selectedCategory = 'Tasks'; // Default category
  String selectedTimeFilter = 'Day'; // Default filter
  String formattedTimeFilter = '';
  DateTime selectedDate = DateTime.now();
  bool isLoading = true;
  bool canNavigateForward = true;

  // Placeholder task
  List<TaskTimeSpent> taskTimeSpent = [];
  List<TaskTimeDistribution> taskTimeDistribution = [];
  List<FinishedTask> taskFinished = [];
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
  List<SleepRegularity> sleepRegularity = [];

  @override
  void initState() {
    super.initState();
    _updateFormattedTimeFilter();
    _fetchChartData();
  }

  void _updateFormattedTimeFilter() {
    DateTime today = DateTime.now();
    DateTime startOfWeek =
        selectedDate.subtract(Duration(days: selectedDate.weekday - 1)); // Start of the week
    DateTime endOfWeek =
        startOfWeek.add(const Duration(days: 6)); // End of the week

    switch (selectedTimeFilter) {
      case 'Day':
        formattedTimeFilter = DateFormat('MMMM d, yyyy').format(selectedDate);
        canNavigateForward = selectedDate.isBefore(DateTime(today.year, today.month, today.day));
        break;
      case 'Week':
        formattedTimeFilter =
            '${DateFormat('MMMM d').format(startOfWeek)} — ${DateFormat('MMMM d, y').format(endOfWeek)}';
        canNavigateForward = endOfWeek.isBefore(DateTime(today.year, today.month, today.day));
        break;
      case 'Month':
        formattedTimeFilter = DateFormat('MMMM').format(selectedDate);
        canNavigateForward = selectedDate.isBefore(DateTime(today.year, today.month, 1));
        break;
      case 'Semester':
        formattedTimeFilter = DateFormat('MMMM yyyy').format(selectedDate);
        canNavigateForward = selectedDate.isBefore(DateTime(today.year, today.month, 1));
        break;
      case 'Year':
        formattedTimeFilter = DateFormat('yyyy').format(selectedDate);
        canNavigateForward = selectedDate.year < today.year;
        break;
    }
  }

  void _navigateDate(int direction) {
    setState(() {
      if (direction == -1) {
        // Navigate dates backward
        switch (selectedTimeFilter) {
          case 'Day':
            selectedDate = selectedDate.subtract(Duration(days: 1));
            break;
          case 'Week':
            selectedDate = selectedDate.subtract(Duration(days: 7));
            break;
          case 'Month':
            selectedDate = DateTime(selectedDate.year, selectedDate.month + direction, selectedDate.day);
            break;
          case 'Semester':
            selectedDate = DateTime(selectedDate.year, selectedDate.month + (6 * direction), selectedDate.day);
            break;
          case 'Year': 
            selectedDate = DateTime(selectedDate.year + direction, selectedDate.month, selectedDate.day);
            break;
        }
      } else if (direction == 1 && canNavigateForward) {
        // Navigate dates forward only if allowed
        switch (selectedTimeFilter) {
          case 'Day':
            selectedDate = selectedDate.add(Duration(days: direction));
            break;
          case 'Week':
            selectedDate = selectedDate.add(Duration(days: 7 * direction));
            break;
          case 'Month':
            selectedDate = DateTime(selectedDate.year, selectedDate.month + direction, selectedDate.day);
            break;
          case 'Semester':
            selectedDate = DateTime(selectedDate.year, selectedDate.month + (6 * direction), selectedDate.day);
            break;
          case 'Year':
            selectedDate = DateTime(selectedDate.year + direction, selectedDate.month, selectedDate.day);
            break;
        }
      }
      _updateFormattedTimeFilter();
      _fetchChartData();
    });
  }

  Future<void> _fetchChartData() async {
    // await Future.delayed(const Duration(seconds: 1), () {
    try {
      // Instantiation of Providers
      final taskLogProvider =
        Provider.of<TaskTimeLogProvider>(context, listen: false);
      final attendedEventsProvider = 
        Provider.of<AttendedEventsProvider>(context, listen: false);
      final activityLogProvider =
        Provider.of<ActivityTimeLogProvider>(context, listen: false);
      final sleepLogProvider = 
        Provider.of<SleepLogProvider>(context, listen: false);

      // Instantiation of Placeholder Lists
      List<TaskTimeLog>? taskTimeLogs;
      List<AttendedEvent>? attendedEvents;
      List<ActivityTimeLog>? activityTimeLogs;
      List<SleepLog>? sleepLogs;

      // ---------- Fetching of Records ----------
      switch (selectedCategory) {
        case 'Tasks':
          taskTimeLogs = await ReportsService.fetchTaskLogsOnce(
            taskLogProvider: taskLogProvider, 
            selectedTimeFilter: selectedTimeFilter,
            selectedDate: selectedDate
          );

          // Process TaskTimeSpent
          taskTimeSpent = await ReportsService.fetchTaskTimeSpent(
            taskTimeLogs: taskTimeLogs, 
            selectedTimeFilter: selectedTimeFilter
          );

          // Process TaskTimeDistribution
          taskTimeDistribution = await ReportsService.fetchTaskTimeDistribution(
            taskTimeLogs: taskTimeLogs, 
            selectedTimeFilter: selectedTimeFilter
          );

          // Process TaskTimeDistribution
          taskFinished = await ReportsService.fetchTasksFinished(
            taskTimeLogs: taskTimeLogs, 
            selectedTimeFilter: selectedTimeFilter
          );
          break;
        case 'Events':
          attendedEvents = await ReportsService.fetchEventLogsOnce(
            attendedEventsProvider: attendedEventsProvider, 
            selectedTimeFilter: selectedTimeFilter,
            selectedDate: selectedDate
          );

          // Process EventAttendanceSummary
          eventAttendanceSummary = await ReportsService.fetchEventAttendanceSummary(
            attendedEvents: attendedEvents, 
            selectedTimeFilter: selectedTimeFilter
          );

          // Process EventTypeDistribution
          eventTypeDistribution = await ReportsService.fetchEventTypeDistribution(
            attendedEvents: attendedEvents, 
            selectedTimeFilter: selectedTimeFilter
          );

          // Process EventAttendanceDistribution
          eventAttendanceDistribution = await ReportsService.fetchEventAttendanceDistribution(
            attendedEvents: attendedEvents, 
            selectedTimeFilter: selectedTimeFilter
          );
          break;
        case 'Class Schedules':
          // To be added
          break;
        case 'Activities':
          activityTimeLogs = await ReportsService.fetchActivityLogsOnce(
            activityLogProvider: activityLogProvider, 
            selectedTimeFilter: selectedTimeFilter,
            selectedDate: selectedDate
          );

          // Process ActivitiesTimeSpent
          activitiesTimeSpent = await ReportsService.fetchActivityTimeSpent(
            activityTimeLogs: activityTimeLogs, 
            selectedTimeFilter: selectedTimeFilter
          );

          // Process ActivitiesDone
          activitiesDone = await ReportsService.fetchActivitiesDone(
            activityTimeLogs: activityTimeLogs, 
            selectedTimeFilter: selectedTimeFilter
          );
          break;
        case 'Goals':
          // To be added
          break;
        case 'Sleep':
          sleepLogs = await ReportsService.fetchSleepLogsOnce(
            sleepLogProvider: sleepLogProvider, 
            selectedTimeFilter: selectedTimeFilter,
            selectedDate: selectedDate
          );
          
          // Process SleepDuration
          sleepDuration = await ReportsService.fetchSleepDuration(
            sleepLogs: sleepLogs, 
            selectedTimeFilter: selectedTimeFilter
          );
      }
      
      if (!mounted) return; // Ensure the widget is still mounted before calling setState
      setState(() {
        // Example data for class schedules
        classAttendanceSummary = [
          ClassAttendanceSummary('Attended', 55),
          ClassAttendanceSummary('Excused', 12),
          ClassAttendanceSummary('Did Not Attend', 12),
        ];

        classAttendanceDistribution = [
          ClassAttendanceDistribution('IT311', 1, 1, 2),
          ClassAttendanceDistribution('IT312', 1, 1, 2),
          ClassAttendanceDistribution('IT313', 2, 3, 0),
          ClassAttendanceDistribution('IT314', 1, 1, 1),
          ClassAttendanceDistribution('IT315', 1, 2, 2),
          ClassAttendanceDistribution('ES21a', 0, 0, 3),
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

        // // Example data for sleep
        sleepRegularity = [
          SleepRegularity('Sun', 23.0, 8.0),
          SleepRegularity('Mon', 22.0, 5.0),
          SleepRegularity('Tue', 2.0, 10.0),
          SleepRegularity('Fri', 23.0, 8.0)
        ];

        isLoading = false;
      });
    } catch (error) {
      print("Failed to fetch chart data: $error");
      setState(() {
        isLoading = false;
      });
    }
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
        title: Text(
          'Reports', 
          style: GoogleFonts.openSans(
            fontWeight: FontWeight.bold, 
            color: Color(0xFF173F70),
          ),
        ),
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
                        _fetchChartData();
                      },
                      initialSelection: selectedCategory,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(40.0),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            selectedCategory,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.openSans(
                              fontSize: 15,
                              color: const Color(0xFF173F70),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Icon(Icons.arrow_drop_down,
                            color: const Color(0xFF173F70)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                // Time filter buttons
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ToggleButtonsDemo(
                    labels: ['Day', 'Week', 'Month', 'Semester', 'Year'],
                    onSelected: _onTimeFilterSelected,
                  ),
                ),

                const SizedBox(height: 8.0),
                // Display the selected time range
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () => _navigateDate(-1),
                      color: Color(0xFF173F70),
                    ),
                    SizedBox(width: 16),
                    Text(
                      formattedTimeFilter.isNotEmpty
                          ? formattedTimeFilter
                          : 'No date/range selected',
                      style: GoogleFonts.openSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF173F70),
                      ),
                    ),
                    SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: canNavigateForward 
                          ? () => _navigateDate(1)
                          : null,
                      color: canNavigateForward 
                          ? Color(0xFF173F70)
                          : Colors.white,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Scrollable charts
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
                child: Column(
                  children: [
                    // TASKS category
                    if (selectedCategory == 'Tasks') ...[
                      TaskCharts(
                        isLoading: isLoading,
                        timeFilter: selectedTimeFilter,
                        selectedDate: selectedDate,
                        taskTimeSpent: taskTimeSpent,
                        taskTimeDistribution: taskTimeDistribution,
                        taskFinished: taskFinished,
                      ),
                    ],
                    // EVENTS category
                    if (selectedCategory == 'Events') ...[
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
                        timeFilter: selectedTimeFilter,
                        selectedDate: selectedDate,
                        activitiesTimeSpent: activitiesTimeSpent,
                        activitiesDone: activitiesDone,
                      ),
                    ],
                    if (selectedCategory == 'Goals') ...[
                      GoalsCharts(
                        isLoading: isLoading,
                        timeFilter: selectedTimeFilter,
                        selectedDate: selectedDate,
                        goalTimeSpent: goalTimeSpent,
                      ),
                    ],
                    if (selectedCategory == 'Sleep') ...[
                      SleepCharts(
                        isLoading: isLoading,
                        timeFilter: selectedTimeFilter,
                        selectedDate: selectedDate,
                        sleepDuration: sleepDuration,
                        sleepRegularity: sleepRegularity,
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
