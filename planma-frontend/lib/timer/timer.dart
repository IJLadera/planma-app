import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'package:planma_app/timer/timer_provider.dart';
import 'package:provider/provider.dart';

class TimerWidget extends StatefulWidget {
  final Color themeColor;
  const TimerWidget({super.key, required this.themeColor});

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  @override
  Widget build(BuildContext context) {
    final timerProvider = Provider.of<TimerProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
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
                  value: timerProvider.initialTime > 0
                      ? timerProvider.remainingTime / timerProvider.initialTime
                      : 0,
                  strokeWidth: 8,
                  color: widget.themeColor,
                ),
              ),
              GestureDetector(
                onTap: () => _showTimePicker(context, timerProvider),
                child: Text(
                  _formatTime(timerProvider.remainingTime),
                  style: GoogleFonts.openSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 45,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 60),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  if (timerProvider.isRunning) {
                    timerProvider.stopTimer(); // Stop the timer
                    // Show Save Confirmation Dialog after stopping the timer
                    _showSaveConfirmationDialog(context, timerProvider);
                  } else {
                    timerProvider.startTimer(); // Start the timer
                  }
                },
                child: Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.themeColor,
                  ),
                  child: Icon(
                    timerProvider.isRunning ? Icons.stop : Icons.play_arrow,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Helper Methods
  void _showSaveConfirmationDialog(BuildContext context, TimerProvider timerProvider) {
    if (timerProvider.remainingTime > 0) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirm Save'),
            content: Text(
                'Are you sure you want to save the time log? The timer stopped at ${_formatTime(timerProvider.remainingTime)}'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  timerProvider.startTimer(); // Continue the timer
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  timerProvider.saveTimeSpent(context); // Save time spent
                  timerProvider.resetTimer();
                  Navigator.of(context).pop(); // Close the dialog after saving
                },
                child: Text('Save'),
              ),
            ],
          );
        },
      );
    }
  }

  void _showTimePicker(BuildContext context, TimerProvider timerProvider) {
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
}

