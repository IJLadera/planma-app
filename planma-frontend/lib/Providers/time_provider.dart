import 'dart:async';
import 'package:flutter/material.dart';

class TimeProvider with ChangeNotifier {
  // Timer Logic
  int remainingTime = 0; // Time in seconds
  int initialTime = 0; // Original timer duration
  bool isRunning = false;
  Timer? _timer;

  // Stopwatch Logic
  int elapsedTime = 0; // Time in seconds
  bool isStopwatchRunning = false;
  Timer? _stopwatchTimer;

  // List to store recorded times
  List<int> recordedTimes = [];

  // Timer Methods
  void setTime(int seconds) {
    remainingTime = seconds;
    initialTime = seconds;
    notifyListeners();
  }

  void startTimer() {
    if (remainingTime > 0 && !isRunning) {
      isRunning = true;
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (remainingTime > 0) {
          remainingTime--;
        } else {
          timer.cancel();
          isRunning = false;
        }
        notifyListeners();
      });
    }
  }

  void pauseTimer() {
    _timer?.cancel();
    isRunning = false;
    notifyListeners();
  }

  void resetTimer() {
    _timer?.cancel();
    remainingTime = initialTime;
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
    _stopwatchTimer?.cancel();
    isStopwatchRunning = false;
    notifyListeners();
  }

  void resetStopwatch() {
    _stopwatchTimer?.cancel();
    elapsedTime = 0;
    isStopwatchRunning = false;
    notifyListeners();
  }

  // Save final stopwatch time
  void saveFinalTime() {
    recordedTimes.add(elapsedTime);
    notifyListeners();
  }
}
