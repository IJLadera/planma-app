import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:planma_app/Providers/time_provider.dart';
import 'package:provider/provider.dart';

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  bool disableBackButton = false; // Controls back button availability

  @override
  Widget build(BuildContext context) {
    final timeProvider = Provider.of<TimeProvider>(context);

    return WillPopScope(
      onWillPop: () async {
        // Disable the back button functionality only when it's disabled
        return !disableBackButton;
      },
      child: Scaffold(
        backgroundColor: Colors.blue[100],
        appBar: AppBar(
          backgroundColor: Colors.blue[100],
          title: const Text("Countdown Timer"),
          leading: disableBackButton
              ? null // Remove back button if disabled
              : IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context); // Navigate back if enabled
                  },
                ),
        ),
        body: Center(
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
                          ? timeProvider.remainingTime /
                              timeProvider.initialTime
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
                          disableBackButton = false; // Enable back button
                        });
                      } else {
                        timeProvider.startTimer();
                        setState(() {
                          disableBackButton = true; // Disable back button
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
                        disableBackButton = false; // Enable back button
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
        ),
      ),
    );
  }

  // Displays the CupertinoTimerPicker to select the timer duration
  void _showTimePicker(BuildContext context, TimeProvider timerProvider) {
    timerProvider.pauseTimer(); // Pause the timer during editing
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

  // Formats the remaining time into a readable string (HH:MM:SS)
  String _formatTime(int totalSeconds) {
    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    int seconds = totalSeconds % 60;
    return "${hours.toString().padLeft(2, "0")}:${minutes.toString().padLeft(2, "0")}:${seconds.toString().padLeft(2, "0")}";
  }
}
