import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:planma_app/Providers/time_provider.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:planma_app/reports/report_page.dart';
import 'package:google_fonts/google_fonts.dart';

class TimerPage extends StatefulWidget {
  final Color themeColor;

  const TimerPage({super.key, required this.themeColor});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  bool disableBackButton = false; // Controls back button visibility
  bool isTimerMode = true; // Toggles between Timer and Stopwatch
  Timer? _stopwatchTimer;
  int _stopwatchElapsed = 0;
  bool _isStopwatchRunning = false;

  // Store saved times for Timer and Stopwatch
  final List<String> _recordedTimes = [];

  @override
  Widget build(BuildContext context) {
    final timeProvider = Provider.of<TimeProvider>(context);

    return WillPopScope(
      onWillPop: () async {
        return !disableBackButton;
      },
      child: Scaffold(
        backgroundColor: widget.themeColor.withOpacity(0.1),
        appBar: AppBar(
          backgroundColor: widget.themeColor,
          title: Text(
            "Timer & Stopwatch",
            style: GoogleFonts.openSans(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white, // Adjust the color based on your app theme
            ),
          ),
          leading: disableBackButton
              ? null
              : IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ToggleButtons(
                  isSelected: [isTimerMode, !isTimerMode],
                  onPressed: timeProvider.isRunning || _isStopwatchRunning
                      ? null // Disable switching between modes if timer or stopwatch is running
                      : (index) {
                          setState(() {
                            isTimerMode = index == 0;
                          });
                        },
                  borderRadius: BorderRadius.circular(10),
                  selectedColor: Colors.white,
                  fillColor: widget.themeColor,
                  children: [
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      child: Text(
                        "Timer",
                        style: GoogleFonts.openSans(
                            fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "Stopwatch",
                        style: GoogleFonts.openSans(
                            fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
              // Conditionally Render Timer or Stopwatch
              isTimerMode
                  ? _buildTimerView(context, timeProvider)
                  : _buildStopwatchView(),
              const SizedBox(height: 20),
              // Display Recorded Times
              _buildRecordedTimesView(),
              // Button to navigate to Reports Page
              // ElevatedButton(
              //   onPressed: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (context) => ReportsPage(recordedTimes: _recordedTimes), // error fixed here
              //       ),
              //     );
              //   },
              //   style: ElevatedButton.styleFrom(
              //     backgroundColor: widget.themeColor,
              //   ),
              //   child: const Text("View Reports"),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  // Timer View
  Widget _buildTimerView(BuildContext context, TimeProvider timeProvider) {
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
                  value: timeProvider.initialTime > 0
                      ? timeProvider.remainingTime / timeProvider.initialTime
                      : 0,
                  strokeWidth: 8,
                  color: widget.themeColor,
                ),
              ),
              GestureDetector(
                onTap: () => _showTimePicker(context, timeProvider),
                child: Text(
                  _formatTime(timeProvider.remainingTime),
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
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.themeColor,
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
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.themeColor,
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
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (!_isStopwatchRunning && _stopwatchElapsed > 0) {
                _saveRecordedTime(_formatTime(_stopwatchElapsed));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.themeColor,
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.save, color: Colors.white),
                const SizedBox(height: 4),
                Text(
                  "Save",
                  style: GoogleFonts.openSans(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Stopwatch View
  Widget _buildStopwatchView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
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
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.themeColor,
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
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.themeColor,
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
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (!_isStopwatchRunning && _stopwatchElapsed > 0) {
                _saveRecordedTime(_formatTime(_stopwatchElapsed));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.themeColor,
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.save, color: Colors.white),
                const SizedBox(height: 4),
                Text("Save", style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Display Recorded Times
  Widget _buildRecordedTimesView() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      height: 200,
      child: _recordedTimes.isEmpty
          ? Center(
              child: Text(
                "No recorded times",
                style: GoogleFonts.openSans(
                  fontSize: 14,
                ),
              ),
            )
          : ListView.builder(
              itemCount: _recordedTimes.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.history),
                  title: Text(_recordedTimes[index]),
                );
              },
            ),
    );
  }

  // Helper Methods
  void _saveRecordedTime(String time) {
    setState(() {
      _recordedTimes.add(time);
    });
  }

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
    setState(() {
      _stopwatchElapsed = 0;
      _isStopwatchRunning = false;
      _stopwatchTimer?.cancel();
    });
  }
}
