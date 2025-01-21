import 'dart:async';
import 'package:flutter/material.dart';

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
  void saveTimeLog() {
    stopStopwatch(); // Ensure the stopwatch is stopped
    print("Time spent: $elapsedTime seconds");
  }
}