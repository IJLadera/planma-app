import 'dart:async';
import 'package:flutter/material.dart';

class TimeProvider with ChangeNotifier {
  int remainingTime = 0; // Time in seconds
  int initialTime = 0; // Original timer duration
  bool isRunning = false;
  Timer? _timer;

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
}
