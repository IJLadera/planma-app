import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:planma_app/Providers/time_provider.dart';
import 'package:provider/provider.dart';
import 'dart:async';

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  bool disableBackButton = false; // Controls back button visibility
  bool isTimerMode = true; // Toggles between Timer and Stopwatch
  Timer? _stopwatchTimer;
  int _stopwatchElapsed = 0;
  bool _isStopwatchRunning = false;

  @override
  Widget build(BuildContext context) {
    final timeProvider = Provider.of<TimeProvider>(context);

    return WillPopScope(
      onWillPop: () async {
        return !disableBackButton; // Prevent back navigation when disabled
      },
      child: Scaffold(
        backgroundColor: Colors.blue[100],
        appBar: AppBar(
          backgroundColor: Colors.blue[100],
          title: const Text("Timer & Stopwatch"),
          leading: disableBackButton
              ? null
              : IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
        ),
        body: Column(
          children: [
            // Toggle Buttons for Timer/Stopwatch
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ToggleButtons(
                isSelected: [isTimerMode, !isTimerMode],
                onPressed: (index) {
                  setState(() {
                    isTimerMode = index == 0;
                  });
                },
                borderRadius: BorderRadius.circular(10),
                selectedColor: Colors.white,
                fillColor: Colors.blue,
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text("Timer"),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text("Stopwatch"),
                  ),
                ],
              ),
            ),

            // Conditionally Render Timer or Stopwatch
            Expanded(
              child: isTimerMode
                  ? _buildTimerView(context, timeProvider)
                  : _buildStopwatchView(),
            ),
          ],
        ),
      ),
    );
  }

  // Timer View
  Widget _buildTimerView(BuildContext context, TimeProvider timeProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 280,
                width: 280,
                child: CircularProgressIndicator(
                  backgroundColor: Colors.white,
                  value: timeProvider.initialTime > 0
                      ? timeProvider.remainingTime / timeProvider.initialTime
                      : 0,
                  strokeWidth: 8,
                ),
              ),
              GestureDetector(
                onTap: () => _showTimePicker(context, timeProvider),
                child: Text(
                  _formatTime(timeProvider.remainingTime),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 45,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  if (timeProvider.isRunning) {
                    timeProvider.pauseTimer();
                    setState(() {
                      disableBackButton = false;
                    });
                  } else {
                    timeProvider.startTimer();
                    setState(() {
                      disableBackButton = true;
                    });
                  }
                },
                child: Container(
                  height: 50,
                  width: 50,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue,
                  ),
                  child: Icon(
                    timeProvider.isRunning ? Icons.pause : Icons.play_arrow,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              GestureDetector(
                onTap: () {
                  timeProvider.resetTimer();
                  setState(() {
                    disableBackButton = false;
                  });
                },
                child: Container(
                  height: 50,
                  width: 50,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue,
                  ),
                  child: const Icon(
                    Icons.stop,
                    size: 35,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  // Stopwatch View
  Widget _buildStopwatchView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _formatTime(_stopwatchElapsed),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 45,
            ),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _toggleStopwatch,
                child: Container(
                  height: 50,
                  width: 50,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue,
                  ),
                  child: Icon(
                    _isStopwatchRunning ? Icons.pause : Icons.play_arrow,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              GestureDetector(
                onTap: _resetStopwatch,
                child: Container(
                  height: 50,
                  width: 50,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue,
                  ),
                  child: const Icon(
                    Icons.stop,
                    size: 35,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper Methods (for Timer)
  void _showTimePicker(BuildContext context, TimeProvider timerProvider) {
    timerProvider.pauseTimer();
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          color: Colors.white,
          height: 300,
          child: CupertinoTimerPicker(
            mode: CupertinoTimerPickerMode.hms,
            initialTimerDuration:
                Duration(seconds: timerProvider.remainingTime),
            onTimerDurationChanged: (Duration newDuration) {
              if (newDuration.inSeconds > 0) {
                timerProvider.setTime(newDuration.inSeconds);
              }
            },
          ),
        );
      },
    );
  }

  String _formatTime(int totalSeconds) {
    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    int seconds = totalSeconds % 60;
    return "${hours.toString().padLeft(2, "0")}:${minutes.toString().padLeft(2, "0")}:${seconds.toString().padLeft(2, "0")}";
  }

  // Stopwatch Methods
  void _toggleStopwatch() {
    if (_isStopwatchRunning) {
      _stopwatchTimer?.cancel();
    } else {
      _stopwatchTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _stopwatchElapsed++;
        });
      });
    }
    setState(() {
      _isStopwatchRunning = !_isStopwatchRunning;
    });
  }

  void _resetStopwatch() {
    _stopwatchTimer?.cancel();
    setState(() {
      _stopwatchElapsed = 0;
      _isStopwatchRunning = false;
    });
  }
}
