import 'package:flutter/material.dart';

//-----------------------TASKS----------------------------------

class TaskTimeSpent {
  final String day;
  final double minutes;

  TaskTimeSpent(this.day, this.minutes);
}

class TaskTimeDistribution {
  final String taskName;
  final double percentage;
  final Color color;

  TaskTimeDistribution(this.taskName, this.percentage, this.color);
}

class FinishedTask {
  final String taskName;
  final int count;

  FinishedTask(this.taskName, this.count);
}

//-----------------------EVENTS----------------------------------

class EventAttendancecSummary {
  final String attendance; //attended, did not attended
  final double attendanceCount;
  final Color color;

  EventAttendancecSummary(this.attendance, this.attendanceCount, this.color);
}

class EventTypeDistribution {
  final String eventType; // personal, academic
  final double attendanceCount;
  final Color color;

  EventTypeDistribution(this.eventType, this.attendanceCount, this.color);
}

class EventAttendanceDistribution {
  final String category; //academic, personal
  final double academicCount;
  final double personalCount;

  EventAttendanceDistribution(
      this.category, this.academicCount, this.personalCount);
}

//-----------------------CLASS SCHEDULE----------------------------------
class ClassAttendanceSummary {
  final String category;
  final double percentage;
  final Color color;

  ClassAttendanceSummary(this.category, this.percentage, this.color);
}

class ClassAttendanceDistribution {
  final String subject;
  final int didNotAttend;
  final int excused;
  final int attended;

  ClassAttendanceDistribution(
      this.subject, this.didNotAttend, this.excused, this.attended);
}

//-----------------------ACTIVITIES----------------------------------
class ActivitiesTimeSpent {
  final String day;
  final int minutes;

  ActivitiesTimeSpent(this.day, this.minutes);
}

class ActivitiesDone {
  final String day;
  final int numTask;

  ActivitiesDone(this.day, this.numTask);
}

//-----------------------GOALS----------------------------------
class GoalTimeSpent {
  final String day;
  final int minutes;

  GoalTimeSpent(this.day, this.minutes);
}

//-----------------------SLEEP----------------------------------
class SleepDuration {
  final String day;
  final int hours;

  SleepDuration(this.day, this.hours);
}

//--------------------------------------------------------------
class ToggleButtonsDemo extends StatefulWidget {
  final List<String> labels; // The labels for each toggle button
  final ValueChanged<String> onSelected; // Callback when a button is selected

  const ToggleButtonsDemo({
    required this.labels,
    required this.onSelected,
    super.key,
  });

  @override
  _ToggleButtonsDemoState createState() => _ToggleButtonsDemoState();
}

class _ToggleButtonsDemoState extends State<ToggleButtonsDemo> {
  late List<bool> _selections;

  @override
  void initState() {
    super.initState();
    // Initialize the selections array: first option selected by default
    _selections = List.generate(widget.labels.length, (index) => index == 0);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center, // Center the toggle buttons
      children: [
        ToggleButtons(
          isSelected: _selections,
          onPressed: (int index) {
            setState(() {
              // Clear all selections and activate the selected button
              for (int i = 0; i < _selections.length; i++) {
                _selections[i] = i == index;
              }
            });
            // Call the provided callback with the selected label
            widget.onSelected(widget.labels[index]);
          },
          borderRadius: BorderRadius.circular(8), // Rounded corners
          borderColor: const Color(0xFF173F70), // Default border color
          selectedBorderColor: const Color(0xFF173F70), // Active border color
          fillColor: const Color(0xFF173F70), // Active button background
          selectedColor: Colors.white, // Active button text color
          color: const Color(0xFF173F70),
          // Configure the appearance of the toggle buttons
          children: widget.labels
              .map(
                (label) => SizedBox(
                  width: 90, // Width for uniform button sizes
                  child: Center(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14), // Adjust font size
                    ),
                  ),
                ),
              )
              .toList(), // Default text color
        ),
      ],
    );
  }
}

class ChartContainer extends StatelessWidget {
  final String title;
  final Widget child;
  final bool isLoading;

  const ChartContainer({
    required this.title,
    required this.child,
    required this.isLoading,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SizedBox(
              height: 300,
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : child),
        ],
      ),
    );
  }
}
