import 'dart:async';
import 'package:flutter/material.dart';

class TimeProvider with ChangeNotifier {
  // Timer Logic
  int remainingTime = 0; // Time in seconds
  int initialTime = 0; // Original timer duration
  bool isRunning = false;
  Timer? _timer;
  int elapsedTimeTimer = 0; // Elapsed time for countdown timer

  // Stopwatch Logic
  int elapsedTime = 0; // Time in seconds
  bool isStopwatchRunning = false;
  Timer? _stopwatchTimer;

  // List to store recorded times
  List<String> recordedTimes = [];

  // Timer Methods
  void setTime(int seconds) {
    remainingTime = seconds;
    initialTime = seconds;
    elapsedTimeTimer = 0; // Reset elapsed time when setting new time
    notifyListeners();
  }

  void startTimer() {
    if (remainingTime > 0 && !isRunning) {
      isRunning = true;
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (remainingTime > 0) {
          remainingTime--;
          elapsedTimeTimer++; // Increment elapsed time
        } else {
          timer.cancel();
          isRunning = false;
        }
        notifyListeners();
      });
    }
  }

  void pauseTimer() {
    if (isRunning) {
      _timer?.cancel();
      isRunning = false;
      notifyListeners();
    }
  }

  void resetTimer() {
    _timer?.cancel();
    remainingTime = initialTime;
    elapsedTimeTimer = 0; // Reset elapsed time
    isRunning = false;
    notifyListeners();
  }

  // Stopwatch Methods
  void startStopwatch() {
    if (!isStopwatchRunning) {
      isStopwatchRunning = true;
      _stopwatchTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        elapsedTime++;
        notifyListeners();
      });
    }
  }

  void pauseStopwatch() {
    if (isStopwatchRunning) {
      _stopwatchTimer?.cancel();
      isStopwatchRunning = false;
      notifyListeners();
    }
  }

  void resetStopwatch() {
    _stopwatchTimer?.cancel();
    elapsedTime = 0;
    isStopwatchRunning = false;
    notifyListeners();
  }

  // Save final stopwatch time
  void saveStopwatchTime() {
    final formattedTime = _formatTime(elapsedTime);
    recordedTimes.add(formattedTime);
    notifyListeners();
  }

  // Helper: Format time for display
  String _formatTime(int totalSeconds) {
    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    int seconds = totalSeconds % 60;
    return "${hours.toString().padLeft(2, "0")}:${minutes.toString().padLeft(2, "0")}:${seconds.toString().padLeft(2, "0")}";
  }

  // Return elapsed time of the countdown timer
  int getElapsedTime() {
    return elapsedTimeTimer; // Return the elapsed time for the countdown timer
  }
}
