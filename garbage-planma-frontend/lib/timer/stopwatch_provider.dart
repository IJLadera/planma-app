import 'dart:async';
import 'package:flutter/material.dart';
import 'package:planma_app/Providers/activity_log_provider.dart';
import 'package:planma_app/Providers/activity_provider.dart';
import 'package:planma_app/Providers/goal_progress_provider.dart';
import 'package:planma_app/Providers/sleep_provider.dart';
import 'package:planma_app/Providers/task_log_provider.dart';
import 'package:planma_app/Providers/task_provider.dart';
import 'package:planma_app/models/clock_type.dart';

class StopwatchProvider with ChangeNotifier{
  // Stopwatch state variables
  int elapsedTime = 0;
  bool _isRunning = false;

  bool get isRunning => _isRunning;

  //Timer instance
  Timer? _timer;

  // Start the stopwatch
  void startStopwatch() {
    if (!isRunning) {
      _isRunning = true;
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        elapsedTime++;
        notifyListeners();
      });
      notifyListeners();
    }
  }

  // Stop the stopwatch
  void stopStopwatch() {
    if (isRunning) {
      _isRunning = false;
      _timer?.cancel();
      notifyListeners();
    }
  }

  // Reset the stopwatch
  void resetStopwatch() {
    stopStopwatch(); // Stop the timer
    elapsedTime = 0;
    notifyListeners();
  }

  // Save the elapsed time
  void saveTimeLog({
    required ClockContext clockContext,
    required dynamic record,
    required SleepLogProvider sleepLogProvider,
    required TaskTimeLogProvider taskTimeLogProvider,
    required ActivityTimeLogProvider activityTimeLogProvider,
    required GoalProgressProvider goalProgressProvider,
    required TaskProvider taskProvider,
    required ActivityProvider activityProvider
  }) async {
    stopStopwatch(); // Ensure the stopwatch is stopped
    print("Time spent: $elapsedTime seconds");

    final duration = Duration(seconds: elapsedTime);
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
