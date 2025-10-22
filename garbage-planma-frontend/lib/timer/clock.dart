import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:planma_app/models/clock_type.dart';
import 'package:planma_app/timer/stopwatch.dart';
import 'package:planma_app/timer/stopwatch_provider.dart';
import 'package:planma_app/timer/timer.dart';
import 'package:planma_app/timer/timer_provider.dart';
import 'package:provider/provider.dart';

class ClockScreen extends StatefulWidget {
  final Color themeColor;
  final String title;
  final ClockContext clockContext;
  final dynamic record;

  const ClockScreen({
    super.key, 
    required this.themeColor, 
    required this.title, 
    required this.clockContext, 
    this.record
  });

  @override
  State<ClockScreen> createState() => _ClockScreenState();
}

class _ClockScreenState extends State<ClockScreen> {
  bool isTimerMode = true;

  @override
  void initState() {
    super.initState();
    // Reset the timer when the screen is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final timerProvider = Provider.of<TimerProvider>(context, listen: false);
      timerProvider.resetTimer();

      final stopwatchProvider =
          Provider.of<StopwatchProvider>(context, listen: false);
      stopwatchProvider.resetStopwatch();
    });
  }

  Future<bool> _onWillPop(dynamic provider) async {
    // Type-cast provider to the correct type (TimerProvider or StopwatchProvider)
    if (provider is TimerProvider && provider.isRunning) {
      final shouldExit = await _showSaveConfirmationDialog(context, provider);
      return shouldExit;
    } else if (provider is StopwatchProvider && provider.isRunning) {
      final shouldExit = await _showSaveConfirmationDialog(context, provider);
      return shouldExit;
    }
    return true; // Allow navigation if the timer/stopwatch is not running
  }

  Future<bool> _showSaveConfirmationDialog(
      BuildContext context, dynamic provider) async {
    final isTimer = provider is TimerProvider;
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Confirm Exit",
          style: GoogleFonts.openSans(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Colors.black87,
          ),
        ),
        content: Text(
          isTimer
              ? "The timer is running. Are you sure you want to exit?"
              : "The stopwatch is running. Are you sure you want to exit?",
          style: GoogleFonts.openSans(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Cancel
            child: Text(
              "Cancel",
              style: GoogleFonts.openSans(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xFF173F70),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              // Stop the timer/stopwatch
              if (isTimer) {
                (provider as TimerProvider).stopTimer();
              } else {
                (provider as StopwatchProvider).stopStopwatch();
              }
              Navigator.of(context).pop(true); // Confirm exit
            },
            child: Text(
              "Exit",
              style: GoogleFonts.openSans(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xFFEF4738),
              ),
            ),
          ),
        ],
      ),
    );
    return shouldExit ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final timerProvider = Provider.of<TimerProvider>(context);
    final stopwatchProvider = Provider.of<StopwatchProvider>(context);
    final activeProvider = isTimerMode ? timerProvider : stopwatchProvider;
    final isClockRunning = (activeProvider is TimerProvider)
        ? (activeProvider as TimerProvider).isRunning
        : (activeProvider as StopwatchProvider).isRunning;

    return WillPopScope(
      onWillPop: () => _onWillPop(activeProvider),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: widget.themeColor,
          title: Text(
            widget.title,
            style: GoogleFonts.openSans(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Color(0xFF173F70),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ToggleButtons(
                  isSelected: [isTimerMode, !isTimerMode],
                  onPressed: isClockRunning
                      ? null // Disable toggle if the clock is running
                      : (index) {
                          setState(() {
                            isTimerMode = index == 0;
                          });
                        },
                  borderRadius: BorderRadius.circular(10),
                  selectedColor: Colors.white,
                  fillColor: widget.themeColor,
                  color: isClockRunning
                      ? Colors.grey
                      : Colors.black, // Change color when running
                  disabledColor: Colors.grey,
                  selectedBorderColor: Color(0xFF173F70),
                  borderWidth: 0.5,
                  children: [
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 13, vertical: 10),
                      child: Text(
                        "Timer",
                        style: GoogleFonts.openSans(
                            fontSize: 14, color: Color(0xFF173F70)),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "Stopwatch",
                        style: GoogleFonts.openSans(
                            fontSize: 14, color: Color(0xFF173F70)),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 80),
              // Conditionally Render Timer or Stopwatch
              isTimerMode
                  ? TimerWidget(
                      themeColor: widget.themeColor,
                      clockContext: widget.clockContext,
                      record: widget.record,
                    )
                  : StopwatchWidget(
                      themeColor: widget.themeColor,
                      clockContext: widget.clockContext,
                      record: widget.record,
                    ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
