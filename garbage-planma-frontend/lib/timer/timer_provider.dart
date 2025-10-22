import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:planma_app/Providers/activity_log_provider.dart';
import 'package:planma_app/Providers/activity_provider.dart';
import 'package:planma_app/Providers/goal_progress_provider.dart';
import 'package:planma_app/Providers/goal_schedule_provider.dart';
import 'package:planma_app/Providers/sleep_provider.dart';
import 'package:planma_app/Providers/task_log_provider.dart';
import 'package:planma_app/Providers/task_provider.dart';
import 'package:planma_app/models/clock_type.dart';

class TimerProvider with ChangeNotifier {
  // Timer state variables
  int defaultInitialTime = 3600; // Default initial time in seconds
  int remainingTime = 3600; // Time in seconds
  int initialTime = 3600; // Original timer duration
  int timeSpent = 0; // Time spent while the timer was running
  bool _isRunning = false;

  bool get isRunning => _isRunning;

  // Timer instance
  Timer? _timer;

  // Set initial time based on set scheduled start and end time
  void setInitialTimeFromRecord(String scheduledStartTime, String scheduledEndTime) {
    try {
      final startTime = DateFormat("HH:mm:ss").parse(scheduledStartTime);
      var endTime = DateFormat("HH:mm:ss").parse(scheduledEndTime);

      // Handle overnight crossing (e.g., 22:00 -> 06:00)
      if (endTime.isBefore(startTime)) {
        endTime = endTime.add(Duration(days: 1));
      }

      final duration = endTime.difference(startTime).inSeconds;
      if (duration > 0) {
        initialTime = duration;
        remainingTime = duration;
      } else {
        initialTime = 0;
        remainingTime = 0;
      }
      notifyListeners();
    } catch (e) {
      print("Error parsing time: $e");
    }
  }

  // Reset timer to its default value
  void resetTimer() {
    stopTimer(); // Ensure the timer is stopped
    remainingTime = defaultInitialTime; // Reset to the default initial time
    initialTime = defaultInitialTime; // Reset initial time as well
    timeSpent = 0; // Reset time spent
    notifyListeners();
  }

  // Set the timer's duration
  void setTime(int seconds) {
    remainingTime = seconds;
    initialTime = seconds;
    timeSpent = 0; // Reset time spent when time is updated
    notifyListeners();
  }

  // Start the timer
  void startTimer({Future<void> Function()? onFinished}) {
    if (isRunning || remainingTime <= 0)
      return; // Prevent multiple timers or starting when time is 0
    _isRunning = true;
    notifyListeners(); // Notify immediately to update the UI

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (remainingTime > 0) {
        remainingTime--;
        timeSpent++; // Increment time spent
      } else {
        stopTimer(); // Stop the timer when it reaches 0
        notifyListeners(); // Notify first to update UI
        if (onFinished != null) {
          await onFinished(); // Call the auto-save and popup logic
        }
      }
      notifyListeners();
    });
  }

  // Stop the timer
  void stopTimer() {
    if (!isRunning) return; // Prevent stopping if the timer isn't running
    _timer?.cancel();
    _isRunning = false;
    notifyListeners();
  }

  // Save and print the time spent
  Future<void> saveTimeSpent({
    required ClockContext clockContext,
    required dynamic record,
    required SleepLogProvider sleepLogProvider,
    required TaskTimeLogProvider taskTimeLogProvider,
    required ActivityTimeLogProvider activityTimeLogProvider,
    required GoalProgressProvider goalProgressProvider,
    required TaskProvider taskProvider,
    required ActivityProvider activityProvider,
    required GoalScheduleProvider goalScheduleProvider
  }) async {
    stopTimer(); // Ensure the timer is stopped
    print("Time spent: $timeSpent seconds");

    final duration = Duration(seconds: timeSpent);
    final now = DateTime.now();
    final startTime = now.subtract(duration);
    final endTime = now;

    try {
      switch (clockContext.type) {
        // If Timer is for Sleep
        case ClockContextType.sleep:
          await sleepLogProvider.addSleepLog(
              startTime: startTime,
              endTime: endTime,
              duration: duration,
              dateLogged: now
          );
          print("Sleep log successfully saved");
          break;

        // If Timer is for Task
        case ClockContextType.task:
          if (record.taskId == null) {
            throw ArgumentError("Task ID must be provided for task logs.");
          }
          await taskTimeLogProvider.addTaskTimeLog(
              taskId: record.taskId,
              startTime: startTime,
              endTime: endTime,
              duration: duration,
              dateLogged: now
          );
          // Update task status in the TaskProvider
          taskProvider.updateTaskStatus(record.taskId, "Completed");
          print("Task log successfully saved");
          break;

        // If Timer is for Activity
        case ClockContextType.activity:
          if (record.activityId == null) {
            throw ArgumentError(
                "Activity ID must be provided for activity logs.");
          }
          await activityTimeLogProvider.addActivityTimeLog(
              activityId: record.activityId,
              startTime: startTime,
              endTime: endTime,
              duration: duration,
              dateLogged: now
          );
          // Update activity status in the ActivityProvider
          activityProvider.updateActivityStatus(record.activityId, "Completed");
          print("Activity log successfully saved");
          break;

        // If Timer is for Goal
        case ClockContextType.goal:
          if (record.goal!.goalId == null || record.goalScheduleId == null) {
            throw ArgumentError(
                "Goal ID or Goal Schedule ID must be provided for goal session logs.");
          }
          await goalProgressProvider.addGoalProgressLog(
              goalId: record.goal!.goalId,
              goalScheduleId: record.goalScheduleId,
              startTime: startTime,
              endTime: endTime,
              duration: duration,
              dateLogged: now
          );
          // Update goal schedule status in the GoalScheduleProvider
          goalScheduleProvider.updateGoalScheduleStatus(record.goalScheduleId, "Completed");
          print("Goal session log successfully saved");
          break;
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  // Dispose the timer when the provider is no longer used
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
