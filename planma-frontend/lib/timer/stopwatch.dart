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

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(
            _formatTime(stopwatchProvider.elapsedTime),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 45,
            ),
          ),
          const SizedBox(height: 100),
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
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.themeColor,
              ),
              child: Icon(
                stopwatchProvider.isRunning ? Icons.stop : Icons.play_arrow,
                size: 50,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper Methods
  void _showSaveConfirmationDialog(
      BuildContext context, StopwatchProvider stopwatchProvider) {
    if (stopwatchProvider.elapsedTime > 0) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Text(
              'Confirm Save',
              style: GoogleFonts.openSans(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF173F70),
              ),
            ),
            content: RichText(
              text: TextSpan(
                style: GoogleFonts.openSans(
                  fontSize: 16,
                  color: Colors.black54,
                ),
                children: [
                  const TextSpan(
                      text:
                          'Are you sure you want to save the time log? The stopwatch stopped at '),
                  TextSpan(
                    text: _formatTime(stopwatchProvider.elapsedTime),
                    style: GoogleFonts.openSans(
                      fontWeight: FontWeight.bold,
                      color:
                          Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context)
                      .pop(); // Close the dialog without saving
                  stopwatchProvider.startStopwatch(); // Resume the stopwatch
                },
                style: TextButton.styleFrom(
                  foregroundColor: Color(0xFFEF4738),
                  textStyle: GoogleFonts.openSans(
                      fontSize: 14, fontWeight: FontWeight.bold),
                ),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  stopwatchProvider.saveTimeLog(context); // Save the time log
                  stopwatchProvider.resetStopwatch(); // Reset the stopwatch
                  Navigator.of(context).pop(); // Close the dialog after saving
                },
                style: TextButton.styleFrom(
                  foregroundColor: Color(0xFF173F70),
                  textStyle: GoogleFonts.openSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text('Save'),
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
