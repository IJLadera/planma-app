import 'dart:async';
import 'package:flutter/material.dart';
import 'package:planma_app/Providers/sleep_provider.dart';
import 'package:provider/provider.dart';

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
  void saveTimeLog(BuildContext context) async {
    stopStopwatch(); // Ensure the stopwatch is stopped
    print("Time spent: $elapsedTime seconds");

    final sleepLogProvider = Provider.of<SleepLogProvider>(context, listen: false);

    final duration = Duration(seconds: elapsedTime);
    final now = DateTime.now();
    final startTime = now.subtract(duration);
    final endTime = now;

    print('Start Time: $startTime');
    print('End Time: $endTime');
    print('Duration: $duration');
    print('Date Logged: $now');

    try {
      await sleepLogProvider.addSleepLog(
        startTime: startTime, 
        endTime: endTime, 
        duration: duration, 
        dateLogged: now
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sleep log saved successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save sleep log: $e')),
    );
    }
  }

  // Dispose the timer when the provider is no longer used
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
