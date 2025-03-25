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
import 'package:planma_app/reports/widget/class.dart';

class ReportsService {
  // ---------- Utility Function ----------
  static Map<String, String> _calculateDateRange(String selectedTimeFilter, DateTime selectedDate,) {
    // Dates Calculation
    String startDate;
    String endDate;

    DateTime startOfWeek = selectedDate.subtract(Duration(days: selectedDate.weekday - 1));
    DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));

    switch (selectedTimeFilter) {
      case 'Week':
        startDate = DateFormat('yyyy-MM-dd').format(startOfWeek);
        endDate = DateFormat('yyyy-MM-dd').format(endOfWeek);
        break;
      case 'Month':
        startDate = DateFormat('yyyy-MM-01').format(selectedDate);
        endDate = DateFormat('yyyy-MM-dd')
            .format(DateTime(selectedDate.year, selectedDate.month + 1, 0));
        break;
      case 'Year':
        startDate = DateFormat('yyyy-01-01').format(selectedDate);
        endDate = DateFormat('yyyy-12-31').format(selectedDate);
        break;
      case 'Semester':
        if (selectedDate.month <= 6) {
          startDate = DateFormat('yyyy-01-01').format(selectedDate);
          endDate = DateFormat('yyyy-06-30').format(selectedDate);
        } else {
          startDate = DateFormat('yyyy-07-01').format(selectedDate);
          endDate = DateFormat('yyyy-12-31').format(selectedDate);
        }
        break;
      case 'Day':
      default:
        startDate = DateFormat('yyyy-MM-dd').format(selectedDate);
        endDate = startDate;
        break;
    }

    return {'startDate': startDate, 'endDate': endDate};
  }
  
  // ---------- Fetching Data Once ----------
  static Future<List<TaskTimeLog>> fetchTaskLogsOnce({
    required TaskTimeLogProvider taskLogProvider,
    required String selectedTimeFilter,
    required DateTime selectedDate,
  }) async {
    var dateRange = _calculateDateRange(selectedTimeFilter, selectedDate);

    await taskLogProvider.fetchTaskTimeLogs(
      startDate: dateRange['startDate']!,
      endDate: dateRange['endDate']!,
    );

    return taskLogProvider.taskTimeLogs;
  }

  static Future<List<AttendedEvent>> fetchEventLogsOnce({
    required AttendedEventsProvider attendedEventsProvider,
    required String selectedTimeFilter,
    required DateTime selectedDate,
  }) async {
    var dateRange = _calculateDateRange(selectedTimeFilter, selectedDate);

    await attendedEventsProvider.fetchAttendedEvents(
      startDate: dateRange['startDate']!,
      endDate: dateRange['endDate']!,
    );

    return attendedEventsProvider.attendedEvents;
  }

  static Future<List<ActivityTimeLog>> fetchActivityLogsOnce({
    required ActivityTimeLogProvider activityLogProvider,
    required String selectedTimeFilter,
    required DateTime selectedDate,
  }) async {
    var dateRange = _calculateDateRange(selectedTimeFilter, selectedDate);

    await activityLogProvider.fetchActivityTimeLogs(
      startDate: dateRange['startDate']!,
      endDate: dateRange['endDate']!,
    );

    return activityLogProvider.activityTimeLogs;
  }

  static Future<List<SleepLog>> fetchSleepLogsOnce({
    required SleepLogProvider sleepLogProvider,
    required String selectedTimeFilter,
    required DateTime selectedDate,
  }) async {
    var dateRange = _calculateDateRange(selectedTimeFilter, selectedDate);

    await sleepLogProvider.fetchSleepLogs(
      startDate: dateRange['startDate']!,
      endDate: dateRange['endDate']!,
    );

    return sleepLogProvider.sleepLogs;
  }

  // ---------- CHARTS ----------
  // ---------- Tasks ----------
  // Task Chart 1
  static Future<List<TaskTimeSpent>> fetchTaskTimeSpent({
    required List<TaskTimeLog> taskTimeLogs,
    required String selectedTimeFilter,
  }) async {
    Map<String, Duration> timeSpentByDay = {};
    Duration totalDuration = Duration.zero;

    for (var log in taskTimeLogs) {
      DateTime loggedDate = DateTime.parse(log.dateLogged);
      String groupKey; // Group data based on filter

      // Convert duration (HH:mm:ss) to Duration object
      List<String> timeParts = log.duration.split(":");
      Duration logDuration = Duration(
        hours: int.parse(timeParts[0]),
        minutes: int.parse(timeParts[1]),
        seconds: int.parse(timeParts[2]),
      );

      // Add total duration for Total Time Spent
      totalDuration += logDuration;

      // Determine grouping key based on selectedTimeFilter
      switch (selectedTimeFilter) {
        case 'Week':
          groupKey = DateFormat('EEE').format(loggedDate); // Mon, Tue, etc.
          break;
        case 'Month':
          groupKey = DateFormat('dd').format(loggedDate); // 01, 02, ..., 31
          break;
        case 'Year':
          groupKey = DateFormat('MMM').format(loggedDate); // Jan, Feb, ..., Dec
          break;
        case 'Semester':
          int month = loggedDate.month;
          if (month <= 6) {
            groupKey = 'H1'; // First half of year
          } else {
            groupKey = 'H2'; // Second half of year
          }
          break;
        default:
          groupKey = DateFormat('yyyy-MM-dd').format(loggedDate); // Exact date
          break;
      }

      // Sum up durations per groupKey
      if (timeSpentByDay.containsKey(groupKey)) {
        timeSpentByDay[groupKey] = timeSpentByDay[groupKey]! + logDuration;
      } else {
        timeSpentByDay[groupKey] = logDuration;
      }
    }

    double totalMinutes = totalDuration.inMinutes.toDouble();

    // Convert map to TaskTimeSpent
    List<TaskTimeSpent> taskTimeSpent = timeSpentByDay.entries.map((entry) {
      double minutes = entry.value.inMinutes.toDouble();
      return TaskTimeSpent(entry.key, minutes, totalMinutes);
    }).toList();

    return taskTimeSpent;
  }

  // Task Chart 2
  static Future<List<TaskTimeDistribution>> fetchTaskTimeDistribution({
    required List<TaskTimeLog> taskTimeLogs,
    required String selectedTimeFilter,
  }) async {
    Map<String, Duration> timeSpentBySubject = {};

    for (var log in taskTimeLogs) {
      String subjectCode = log.taskId?.subject?.subjectCode ?? 'Unknown';
      List<String> timeParts = log.duration.split(":");
      Duration logDuration = Duration(
        hours: int.parse(timeParts[0]),
        minutes: int.parse(timeParts[1]),
        seconds: int.parse(timeParts[2]),
      );

      if (timeSpentBySubject.containsKey(subjectCode)) {
        timeSpentBySubject[subjectCode] =
            timeSpentBySubject[subjectCode]! + logDuration;
      } else {
        timeSpentBySubject[subjectCode] = logDuration;
      }
    }

    List<TaskTimeDistribution> taskTimeDistribution = timeSpentBySubject.entries
        .map((entry) => TaskTimeDistribution(
              entry.key,
              entry.value.inMinutes.toDouble(),
            ))
        .toList();

    return taskTimeDistribution;
  }

  // Task Chart 3
  static Future<List<FinishedTask>> fetchTasksFinished({
    required List<TaskTimeLog> taskTimeLogs,
    required String selectedTimeFilter,
  }) async {
    Map<String, int> tasksFinishedBySubject = {};
    int totalCount = 0;

    for (var log in taskTimeLogs) {
      if (log.taskId?.status == "Completed") {
        // Add total count for Total Tasks Finished
        totalCount++;

        String subjectCode = log.taskId?.subject?.subjectCode ?? 'Unknown';

        // Sum up counts per subjectCode
        if (tasksFinishedBySubject.containsKey(subjectCode)) {
          tasksFinishedBySubject[subjectCode] = tasksFinishedBySubject[subjectCode]! + 1;
        } else {
          tasksFinishedBySubject[subjectCode] = 1;
        }
      }
    }

    List<FinishedTask> tasksFinished = tasksFinishedBySubject.entries
        .map((entry) => FinishedTask(
              entry.key,
              entry.value,
              totalCount
            ))
        .toList();

    return tasksFinished;
  }

  // ---------- Events ----------
  // Event Chart 1
  static Future<List<EventAttendancecSummary>> fetchEventAttendanceSummary({
    required List<AttendedEvent> attendedEvents,
    required String selectedTimeFilter,
  }) async {
    Map<String, int> attendedEventsByStatus = {};

    for (var log in attendedEvents) {
      String attendanceStatus = log.hasAttended ? "Attended" : "Did Not Attend";

      if (attendedEventsByStatus.containsKey(attendanceStatus)) {
        attendedEventsByStatus[attendanceStatus] = attendedEventsByStatus[attendanceStatus]! + 1;
      } else {
        attendedEventsByStatus[attendanceStatus] = 1;
      }
    }

    List<EventAttendancecSummary> eventAttendanceSummary = attendedEventsByStatus.entries
        .map((entry) => EventAttendancecSummary(
              entry.key,
              entry.value,
            ))
        .toList();

    return eventAttendanceSummary;
  }
  
  // Event Chart 2
  static Future<List<EventTypeDistribution>> fetchEventTypeDistribution({
    required List<AttendedEvent> attendedEvents,
    required String selectedTimeFilter,
  }) async {
    Map<String, int> eventDistributionByType = {};

    for (var log in attendedEvents) {
      String eventType = log.event?.eventType ?? "Unknown";

      if (eventDistributionByType.containsKey(eventType)) {
        eventDistributionByType[eventType] = eventDistributionByType[eventType]! + 1;
      } else {
        eventDistributionByType[eventType] = 1;
      }
    }

    List<EventTypeDistribution> eventTypeDistribution = eventDistributionByType.entries
        .map((entry) => EventTypeDistribution(
              entry.key,
              entry.value,
            ))
        .toList();

    return eventTypeDistribution;
  }

  // Event Chart 3
  static Future<List<EventAttendanceDistribution>> fetchEventAttendanceDistribution({
    required List<AttendedEvent> attendedEvents,
    required String selectedTimeFilter,
  }) async {
    Map<String, Map<String, int>> eventAttendanceByType = {};

    for (var log in attendedEvents) {
      String eventType = log.event?.eventType ?? "Unknown";
      String attendanceStatus = log.hasAttended ? "Attended" : "Did Not Attend";

      if (!eventAttendanceByType.containsKey(eventType)) {
        eventAttendanceByType[eventType] = {"Attended": 0, "Did Not Attend": 0};
      } 

      eventAttendanceByType[eventType]![attendanceStatus] = 
          eventAttendanceByType[eventType]![attendanceStatus]! + 1;
    }

    List<EventAttendanceDistribution> eventAttendanceDistribution = eventAttendanceByType.entries
        .map((entry) => EventAttendanceDistribution(
              entry.key,
              entry.value["Attended"] ?? 0,
              entry.value["Did Not Attend"] ?? 0,
            ))
        .toList();

    return eventAttendanceDistribution;
  }

  // ---------- Class Schedules ----------




  // ---------- Activities ----------
  // Activity Chart 1
  static Future<List<ActivitiesTimeSpent>> fetchActivityTimeSpent({
    required List<ActivityTimeLog> activityTimeLogs,
    required String selectedTimeFilter,
  }) async {
    Map<String, Duration> activityTimeSpentByDay = {};
    Duration totalDuration = Duration.zero;

    if (activityTimeLogs.isEmpty) {
      print("way sulod");
    } else {
      print("naa");
    }

    for (var log in activityTimeLogs) {
      DateTime loggedDate = DateTime.parse(log.dateLogged);
      String groupKey; // Group data based on filter

      // Convert duration (HH:mm:ss) to Duration object
      List<String> timeParts = log.duration.split(":");
      Duration logDuration = Duration(
        hours: int.parse(timeParts[0]),
        minutes: int.parse(timeParts[1]),
        seconds: int.parse(timeParts[2]),
      );

      // Add total duration for Total Time Spent
      totalDuration += logDuration;

      // Determine grouping key based on selectedTimeFilter
      switch (selectedTimeFilter) {
        case 'Week':
          groupKey = DateFormat('EEE').format(loggedDate); // Mon, Tue, etc.
          break;
        case 'Month':
          groupKey = DateFormat('dd').format(loggedDate); // 01, 02, ..., 31
          break;
        case 'Year':
          groupKey = DateFormat('MMM').format(loggedDate); // Jan, Feb, ..., Dec
          break;
        case 'Semester':
          int month = loggedDate.month;
          if (month <= 6) {
            groupKey = 'H1'; // First half of year
          } else {
            groupKey = 'H2'; // Second half of year
          }
          break;
        default:
          groupKey = DateFormat('yyyy-MM-dd').format(loggedDate); // Exact date
          break;
      }

      // Sum up durations per groupKey
      if (activityTimeSpentByDay.containsKey(groupKey)) {
        activityTimeSpentByDay[groupKey] = activityTimeSpentByDay[groupKey]! + logDuration;
      } else {
        activityTimeSpentByDay[groupKey] = logDuration;
      }
    }

    double totalMinutes = totalDuration.inMinutes.toDouble();

    // Convert map to ActivitiesTimeSpent
    List<ActivitiesTimeSpent> activityTimeSpent = activityTimeSpentByDay.entries.map((entry) {
      double minutes = entry.value.inMinutes.toDouble();
      return ActivitiesTimeSpent(entry.key, minutes, totalMinutes);
    }).toList();

    return activityTimeSpent;
  }

  // Activity Chart 2
  static Future<List<ActivitiesDone>> fetchActivitiesDone({
    required List<ActivityTimeLog> activityTimeLogs,
    required String selectedTimeFilter,
  }) async {
    Map<String, int> activitiesDoneByDay = {};
    int totalCount = 0;

    if (activityTimeLogs.isEmpty) {
      print("way sulod");
    } else {
      print("naa");
    }

    for (var log in activityTimeLogs) {
      DateTime loggedDate = DateTime.parse(log.dateLogged);
      String groupKey; // Group data based on filter

      // Determine grouping key based on selectedTimeFilter
      switch (selectedTimeFilter) {
        case 'Week':
          groupKey = DateFormat('EEE').format(loggedDate); // Mon, Tue, etc.
          break;
        case 'Month':
          groupKey = DateFormat('dd').format(loggedDate); // 01, 02, ..., 31
          break;
        case 'Year':
          groupKey = DateFormat('MMM').format(loggedDate); // Jan, Feb, ..., Dec
          break;
        case 'Semester':
          int month = loggedDate.month;
          if (month <= 6) {
            groupKey = 'H1'; // First half of year
          } else {
            groupKey = 'H2'; // Second half of year
          }
          break;
        default:
          groupKey = DateFormat('yyyy-MM-dd').format(loggedDate); // Exact date
          break;
      }

      if (log.activityId?.status == "Completed") {
        // Add total count for Total Tasks Finished
        totalCount++;
        print("hatdog");

        // Sum up counts per groupKey
        if (activitiesDoneByDay.containsKey(groupKey)) {
          activitiesDoneByDay[groupKey] = activitiesDoneByDay[groupKey]! + 1;
        } else {
          activitiesDoneByDay[groupKey] = 1;
        }
      }
    }

    List<ActivitiesDone> activitiesDone = activitiesDoneByDay.entries
        .map((entry) => ActivitiesDone(
              entry.key,
              entry.value,
              totalCount,
            ))
        .toList();

    return activitiesDone;
  }

  // ---------- Goals ----------
  


  // ---------- Sleep ----------
  // Sleep Chart 1
  static Future<List<SleepDuration>> fetchSleepDuration({
    required List<SleepLog> sleepLogs,
    required String selectedTimeFilter,
  }) async {   
    Map<String, Duration> sleepDurationByDay = {};
    Duration totalDuration = Duration.zero;

    for (var log in sleepLogs) {
      DateTime loggedDate = DateTime.parse(log.dateLogged);
      String groupKey; // Group data based on filter

      // Convert duration (HH:mm:ss) to Duration object
      List<String> timeParts = log.duration.split(":");
      Duration logDuration = Duration(
        hours: int.parse(timeParts[0]),
        minutes: int.parse(timeParts[1]),
        seconds: int.parse(timeParts[2]),
      );

      // Add total duration for Average Hours Slept
      totalDuration += logDuration;

      // Determine grouping key based on selectedTimeFilter
      switch (selectedTimeFilter) {
        case 'Week':
          groupKey = DateFormat('EEE').format(loggedDate); // Mon, Tue, etc.
          break;
        case 'Month':
          groupKey = DateFormat('dd').format(loggedDate); // 01, 02, ..., 31
          break;
        case 'Year':
          groupKey = DateFormat('MMM').format(loggedDate); // Jan, Feb, ..., Dec
          break;
        case 'Semester':
          int month = loggedDate.month;
          if (month <= 6) {
            groupKey = 'H1'; // First half of year
          } else {
            groupKey = 'H2'; // Second half of year
          }
          break;
        default:
          groupKey = DateFormat('yyyy-MM-dd').format(loggedDate); // Exact date
          break;
      }

      // Sum up durations per groupKey
      if (sleepDurationByDay.containsKey(groupKey)) {
        sleepDurationByDay[groupKey] = sleepDurationByDay[groupKey]! + logDuration;
      } else {
        sleepDurationByDay[groupKey] = logDuration;
      }
    }

    double averageHours = (sleepLogs.isNotEmpty)
      ? totalDuration.inMinutes / 60 / sleepLogs.length
      : 0;

    // Convert map to SleepDuration
    List<SleepDuration> sleepDuration = sleepDurationByDay.entries.map((entry) {
      double hours = entry.value.inMinutes / 60;
      print(hours);
      return SleepDuration(entry.key, hours, averageHours);
    }).toList();

    return sleepDuration;
  }

  // Sleep Chart 2
  
}
