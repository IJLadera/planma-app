import 'package:flutter/material.dart';
import 'package:planma_app/Providers/activity_log_provider.dart';
import 'package:planma_app/Providers/activity_provider.dart';
import 'package:planma_app/Providers/attended_class_provider.dart';
import 'package:planma_app/Providers/attended_events_provider.dart';
import 'package:planma_app/Providers/class_schedule_provider.dart';
import 'package:planma_app/Providers/events_provider.dart';
import 'package:planma_app/Providers/goal_progress_provider.dart';
import 'package:planma_app/Providers/goal_provider.dart';
import 'package:planma_app/Providers/goal_schedule_provider.dart';
import 'package:planma_app/Providers/schedule_entry_provider.dart';
import 'package:planma_app/Providers/semester_provider.dart';
import 'package:planma_app/Providers/sleep_provider.dart';
import 'package:planma_app/Providers/task_log_provider.dart';
import 'package:planma_app/Providers/task_provider.dart';
import 'package:planma_app/Providers/user_preferences_provider.dart';
import 'package:planma_app/features/authentication/presentation/providers/user_provider.dart';
import 'package:planma_app/Providers/userprof_provider.dart';
import 'package:planma_app/Providers/web_socket_provider.dart';
import 'package:planma_app/features/splash/presentation/pages/splash_screen.dart';
import 'package:planma_app/reminder/reminder_listener.dart';
import 'package:planma_app/timer/stopwatch_provider.dart';
import 'package:planma_app/timer/timer_provider.dart';
import 'package:provider/provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => UserProfileProvider()),
        ChangeNotifierProvider(create: (context) => ActivityProvider()),
        ChangeNotifierProvider(create: (context) => GoalProvider()),
        ChangeNotifierProvider(create: (context) => SemesterProvider()),
        ChangeNotifierProvider(create: (context) => ClassScheduleProvider()),
        ChangeNotifierProvider(create: (context) => EventsProvider()),
        ChangeNotifierProvider(create: (context) => TaskProvider()),
        ChangeNotifierProvider(create: (context) => GoalScheduleProvider()),
        ChangeNotifierProvider(create: (context) => AttendedEventsProvider()),
        ChangeNotifierProvider(create: (context) => AttendedClassProvider()),
        ChangeNotifierProvider(create: (context) => UserPreferencesProvider()),
        ChangeNotifierProvider(create: (context) => TimerProvider()),
        ChangeNotifierProvider(create: (context) => StopwatchProvider()),
        ChangeNotifierProvider(create: (context) => SleepLogProvider()),
        ChangeNotifierProvider(create: (context) => TaskTimeLogProvider()),
        ChangeNotifierProvider(create: (context) => ActivityTimeLogProvider()),
        ChangeNotifierProvider(create: (context) => GoalProgressProvider()),
        ChangeNotifierProvider(create: (context) => ScheduleEntryProvider()),
        ChangeNotifierProvider(create: (context) => WebSocketProvider()),
        
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: ReminderListener(
          child: SplashController(),
        ),
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.white,
        ),
      ),
    );
  }
}