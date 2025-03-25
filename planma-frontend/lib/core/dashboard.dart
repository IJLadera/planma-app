import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:planma_app/Providers/activity_provider.dart';
import 'package:planma_app/Providers/class_schedule_provider.dart';
import 'package:planma_app/Providers/events_provider.dart';
import 'package:planma_app/Providers/goal_provider.dart';
import 'package:planma_app/Providers/semester_provider.dart';
import 'package:planma_app/Providers/task_provider.dart';
import 'package:planma_app/Providers/user_preferences_provider.dart';
import 'package:planma_app/Providers/userprof_provider.dart';
import 'package:planma_app/activities/activity_page.dart';
import 'package:planma_app/core/widget/button_sheet.dart';
import 'package:planma_app/core/widget/menu_button.dart';
import 'package:planma_app/event/event_page.dart';
import 'package:planma_app/goals/goal_page.dart';
import 'package:planma_app/models/clock_type.dart';
import 'package:planma_app/reports/report_page.dart';
import 'package:planma_app/subject/subject_page.dart';
import 'package:planma_app/task/task_page.dart';
import 'package:planma_app/timer/clock.dart';
import 'package:planma_app/timetable/calendar.dart';
import 'package:planma_app/user_profiile/user_page.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String? selectedSemester;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    final semesterProvider =
        Provider.of<SemesterProvider>(context, listen: false);
    final classScheduleProvider =
        Provider.of<ClassScheduleProvider>(context, listen: false);

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
      } else {
        setState(() {
          selectedSemester = "No semester available";
        });
      }
    });

    // Fetch data for all relevant providers when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().fetchPendingTasks();
      // context.read<ClassScheduleProvider>().fetchClassSchedules(selectedSemesterId: 1);
      context.read<EventsProvider>().fetchUpcomingEvents();
      context.read<ActivityProvider>().fetchPendingActivities();
      context.read<GoalProvider>().fetchGoals();
      context.read<UserPreferencesProvider>().fetchUserPreferences();
    });
  }

  final List<Widget> _screens = [
    Dashboard(),
    CustomCalendar(),
  ];

  void _onItemTapped(int index) {
    if (index == 2) {
      // Open BottomSheet instead of switching screen
      BottomSheetWidget.show(context);
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String? profilePictureUrl = context.watch<UserProfileProvider>().profilePicture;

    // Ensure the URL is absolute
    String getFullImageUrl(String? url) {
      if (url == null || url.isEmpty) return '';
      return url.startsWith('http') ? url : 'http://127.0.0.1:8000$url';
    }

    String profilePictureFullUrl = getFullImageUrl(profilePictureUrl);
    
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Hello, ${context.watch<UserProfileProvider>().username}',
          style: GoogleFonts.openSans(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        foregroundColor: Color(0xFF173F70),
        backgroundColor: Color(0xFFFFFFFF),
        elevation: 2,
        actions: [
          IconButton(
            icon: CircleAvatar(
              backgroundColor: Colors.yellow,
              backgroundImage: profilePictureFullUrl.isNotEmpty
                  ? NetworkImage(profilePictureFullUrl) 
                  : null,
              child: profilePictureUrl == null || profilePictureUrl.isEmpty
                  ? Icon(Icons.person, color: Colors.black)
                  : null,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Let's make a productive plan together",
              style: GoogleFonts.openSans(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Text(
              'Menu',
              style: GoogleFonts.openSans(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  Consumer<TaskProvider>(
                    builder: (context, taskProvider, _) => MenuButtonWidget(
                      color: const Color(0xFF50B6FF),
                      icon: Icons.check_circle,
                      title: 'Tasks',
                      subtitle: '${taskProvider.pendingTasks.length} tasks',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => TasksPage()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 15),
                  Consumer2<ClassScheduleProvider, SemesterProvider>(
                    builder:
                        (context, classScheduleProvider, semesterProvider, _) =>
                            MenuButtonWidget(
                      color: const Color(0xFFFFE1BF),
                      icon: Icons.description,
                      title: 'Class Schedule',
                      subtitle: semesterProvider.semesters.isEmpty
                          ? "0 classes"
                          : '${classScheduleProvider.classSchedules.length} classes',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ClassSchedule()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 15),
                  Consumer<EventsProvider>(
                    builder: (context, eventsProvider, _) => MenuButtonWidget(
                      color: const Color(0xFF7DCFB6),
                      icon: Icons.event,
                      title: 'Events',
                      subtitle:
                          '${eventsProvider.upcomingEvents.length} events',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => EventsPage()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 15),
                  Consumer<ActivityProvider>(
                    builder: (context, activityProvider, _) => MenuButtonWidget(
                      color: const Color(0xFFFBA2A2),
                      icon: Icons.accessibility,
                      title: 'Activities',
                      subtitle:
                          '${activityProvider.pendingActivities.length} activities',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ActivityPage()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 15),
                  Consumer<GoalProvider>(
                    builder: (context, goalProvider, _) => MenuButtonWidget(
                      color: Color(0xFFD7C0F3),
                      icon: FontAwesomeIcons.flag,
                      title: 'Goals',
                      subtitle: '${goalProvider.goals.length} goals',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => GoalPage()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 15),
                  Consumer<UserPreferencesProvider>(
                    builder: (context, userPreferencesProvider, _) =>
                        MenuButtonWidget(
                      color: Color(0xFF535D88),
                      icon: FontAwesomeIcons.moon,
                      title: 'Sleep',
                      subtitle: '',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ClockScreen(
                              themeColor: Color(0xFF535D88),
                              title: "Sleep",
                              clockContext:
                                  ClockContext(type: ClockContextType.sleep),
                              record: userPreferencesProvider.userPreferences[0],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 15),
                  MenuButtonWidget(
                      color: Color(0xFF537488),
                      icon: Icons.bar_chart_outlined,
                      title: 'Reports',
                      subtitle: '',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ReportsPage()),
                        );
                      }),
                  SizedBox(height: 50),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: Container(
          height: 10.0,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30.0),
              topRight: Radius.circular(30.0),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.home, size: 40),
                  color: Color(0xFF173F70),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Dashboard()),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_month, size: 40),
                  color: Color(0xFF173F70),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CustomCalendar()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          BottomSheetWidget.show(context);
        },
        backgroundColor: Color(0xFF173F70),
        shape: const CircleBorder(),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
