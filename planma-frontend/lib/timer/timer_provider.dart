import 'dart:async';
import 'package:flutter/material.dart';

class TimerProvider with ChangeNotifier{
  // Timer state variables
  int defaultInitialTime = 3600; // Default initial time in seconds
  int remainingTime = 3600; // Time in seconds
  int initialTime = 3600; // Original timer duration
  int timeSpent = 0; // Time spent while the timer was running
  bool _isRunning = false;

  bool get isRunning => _isRunning;

  // Timer instance
  Timer? _timer;

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
  void startTimer() {
    if (isRunning || remainingTime <= 0) return; // Prevent multiple timers or starting when time is 0
    _isRunning = true;
    notifyListeners(); // Notify immediately to update the UI

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingTime > 0) {
        remainingTime--;
        timeSpent++; // Increment time spent
      } else {
        stopTimer(); // Stop the timer when it reaches 0
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
  void saveTimeSpent() {
    stopTimer(); // Ensure the timer is stopped
    print("Time spent: $timeSpent seconds");
    // You can save `timeSpent` to persistent storage or database here
  }

  // Dispose the timer when the provider is no longer used
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}