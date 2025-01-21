import 'package:flutter/cupertino.dart';
import 'package:planma_app/timer/stopwatch_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StopwatchWidget extends StatefulWidget {
  final Color themeColor;
  const StopwatchWidget({super.key, required this.themeColor});

  @override
  State<StopwatchWidget> createState() => _StopwatchWidgetState();
}

class _StopwatchWidgetState extends State<StopwatchWidget> {
  
  @override
  Widget build(BuildContext context) {
    final stopwatchProvider = Provider.of<StopwatchProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _formatTime(stopwatchProvider.elapsedTime),
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
                onTap: () {
                  if (stopwatchProvider.isRunning) {
                    stopwatchProvider.stopStopwatch();
                    _showSaveConfirmationDialog(context, stopwatchProvider);
                  } else {
                    stopwatchProvider.startStopwatch();
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
                    stopwatchProvider.isRunning ? Icons.stop : Icons.play_arrow,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 20),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Helper Methods
  void _showSaveConfirmationDialog(BuildContext context, StopwatchProvider stopwatchProvider) {
    if (stopwatchProvider.elapsedTime > 0) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirm Save'),
            content: Text(
                'Are you sure you want to save the time log? The stopwatch stopped at ${_formatTime(stopwatchProvider.elapsedTime)}'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog without saving
                  stopwatchProvider.startStopwatch(); // Resume the stopwatch
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  stopwatchProvider.saveTimeLog(); // Save the time log
                  stopwatchProvider.resetStopwatch(); // Reset the stopwatch
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

  String _formatTime(int totalSeconds) {
    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    int seconds = totalSeconds % 60;
    return "${hours.toString().padLeft(2, "0")}:${minutes.toString().padLeft(2, "0")}:${seconds.toString().padLeft(2, "0")}";
  }
}