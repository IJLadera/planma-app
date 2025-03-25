import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

//-----------------------ABSTRACT CLASS----------------------------------
abstract class ChartData {
  String get displayTitle;
  int get displayCount;
}
//-----------------------TASKS----------------------------------

class TaskTimeSpent {
  final String day;
  final double minutes;
  final double totalTimeSpent;

  TaskTimeSpent(this.day, this.minutes, this.totalTimeSpent);
}

class TaskTimeDistribution {
  final String subName;
  final double percentage;

  TaskTimeDistribution(this.subName, this.percentage);
}

class FinishedTask {
  final String subName;
  final int count;
  final int totalTaskFinished;

  FinishedTask(this.subName, this.count, this.totalTaskFinished);
}

//-----------------------EVENTS----------------------------------

class EventAttendancecSummary implements ChartData {
  final String attendance; //attended, did not attended
  final int attendanceCount;

  EventAttendancecSummary(this.attendance, this.attendanceCount);

  @override
  String get displayTitle => attendance;

  @override
  int get displayCount => attendanceCount;
}

class EventTypeDistribution implements ChartData {
  final String eventType; // personal, academic
  final int attendanceCount;

  EventTypeDistribution(this.eventType, this.attendanceCount);

  @override
  String get displayTitle => eventType;

  @override
  int get displayCount => attendanceCount;
}

class EventAttendanceDistribution {
  final String category; //academic, personal
  final int attendedCount;
  final int didNotAttendCount;

  EventAttendanceDistribution(
      this.category, this.attendedCount, this.didNotAttendCount);
}

//-----------------------CLASS SCHEDULE----------------------------------
class ClassAttendanceSummary implements ChartData{
  final String category;
  final int count;

  ClassAttendanceSummary(this.category, this.count);

  @override
  String get displayTitle => category;

  @override
  int get displayCount => count;
}

class ClassAttendanceDistribution {
  final String subject;
  final int attended;
  final int excused;
  final int didNotAttend;

  ClassAttendanceDistribution(
      this.subject, this.attended, this.excused, this.didNotAttend);
}

//-----------------------ACTIVITIES----------------------------------
class ActivitiesTimeSpent {
  final String day;
  final double minutes;
  final double totalTimeSpent;

  ActivitiesTimeSpent(this.day, this.minutes, this.totalTimeSpent);
}

class ActivitiesDone {
  final String day;
  final int numTask;
  final int totalActivityDone;

  ActivitiesDone(this.day, this.numTask, this.totalActivityDone);
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
  final double hours;
  final double averageHours;

  SleepDuration(this.day, this.hours, this.averageHours);
}

class SleepRegularity {
  final String day;
  final double startTime;
  final double endTime;

  SleepRegularity(this.day, this.startTime, this.endTime);
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
    double screenWidth = MediaQuery.of(context).size.width;
    double buttonWidth =
        (screenWidth / widget.labels.length) - 10; // Responsive width
    double buttonHeight = 30; // Compact height

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
          constraints: BoxConstraints(
            minWidth: buttonWidth, // Responsive width
            minHeight: buttonHeight, // Adjust height
          ),
          // Configure the appearance of the toggle buttons
          children: widget.labels
              .map(
                (label) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.openSans(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ),
              )
              .toList(), // Default text color
        ),
      ],
    );
  }
}

//-----------------------CHART CONTAINERS----------------------------------
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
          Text(
            title,
            style: GoogleFonts.openSans(
              fontSize: 16, 
              fontWeight: FontWeight.bold, 
              color: Color(0xFF173F70),
            ),
          ),
          const Divider(),
          const SizedBox(height: 10),
          SizedBox(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : child),
        ],
      ),
    );
  }
}

class ChartContainer2 extends StatelessWidget {
  final String title;
  final Widget child;
  final bool isLoading;
  final String subtitle;
  final String subtitleValue;

  const ChartContainer2({
    required this.title,
    required this.child,
    required this.isLoading,
    required this.subtitle,
    required this.subtitleValue,
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
          Text(
            title,
            style: GoogleFonts.openSans(
              fontSize: 16, 
              fontWeight: FontWeight.bold, 
              color: Color(0xFF173F70),
            ),
          ),
          const Divider(),
          SizedBox(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : child),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                subtitle,
                style: GoogleFonts.openSans(
                  fontSize: 14, 
                  color: Color(0xFF173F70),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                subtitleValue,
                style: GoogleFonts.openSans(
                  fontSize: 14, 
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF173F70),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ChartContainer3 extends StatelessWidget {
  final String title;
  final Widget child;
  final bool isLoading;
  final List<TaskTimeDistribution> list;

  const ChartContainer3({
    required this.title,
    required this.child,
    required this.isLoading,
    required this.list,
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
          Text(
            title,
            style: GoogleFonts.openSans(
              fontSize: 16, 
              fontWeight: FontWeight.bold, 
              color: Color(0xFF173F70),
            ),
          ),
          const Divider(),
          SizedBox(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : child),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(8),
            itemCount: list.isNotEmpty ? list.length : 1,
            itemBuilder: (context, index) {
              if (list.isEmpty) {
                return ListTile(
                  leading: Icon(
                    Icons.square_rounded,
                    color: Colors.grey.shade300,
                  ),
                  title: Text(
                    "No Data", 
                    style: GoogleFonts.openSans(
                      fontSize: 14, 
                      color: Color(0xFF173F70),
                    ),
                  ),
                  trailing: Text(
                    '0 min', 
                    style: GoogleFonts.openSans(
                      fontSize: 14, 
                      color: Color(0xFF173F70),
                    ),
                  ),
                );
              } else {
                final data = list[index];
                return ListTile(
                  leading: Icon(
                    Icons.square_rounded,
                    color: Colors.primaries[index % Colors.primaries.length],
                  ),
                  title: Text(
                    data.subName, 
                    style: GoogleFonts.openSans(
                      fontSize: 14, 
                      color: Color(0xFF173F70),
                    ),
                  ),
                  trailing: Text(
                    '${data.percentage} min', 
                    style: GoogleFonts.openSans(
                      fontSize: 14, 
                      color: Color(0xFF173F70),
                    ),
                  ),
                );
              }
            },
            separatorBuilder: (context, index) => const Divider(),
          ),
        ],
      ),
    );
  }
}

class ChartContainer4 extends StatelessWidget {
  final String title;
  final Widget child;
  final bool isLoading;
  final List<ChartData> list;
  final Map<String, Color> colorMap;

  const ChartContainer4({
    required this.title,
    required this.child,
    required this.isLoading,
    required this.list,
    required this.colorMap,
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
          Text(
            title,
            style: GoogleFonts.openSans(
              fontSize: 16, 
              fontWeight: FontWeight.bold, 
              color: Color(0xFF173F70),
            ),
          ),
          const Divider(),
          SizedBox(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : child),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(8),
            itemCount: list.isNotEmpty ? list.length : 1,
            itemBuilder: (context, index) {
              if (list.isEmpty) {
                return SizedBox(
                  height: 30,
                  child: ListTile(
                    leading: Icon(
                      Icons.square_rounded,
                      color: Colors.grey.shade300,
                    ),
                    title: Text(
                      "No Data", 
                      style: GoogleFonts.openSans(
                        fontSize: 14, 
                        color: Color(0xFF173F70),
                      ),
                    ),
                    trailing: Text(
                      '0 events', 
                      style: GoogleFonts.openSans(
                        fontSize: 14, 
                        color: Color(0xFF173F70),
                      ),
                    ),
                  ),
                );
              } else {
                final data = list[index];
                return SizedBox(
                  height: 30,
                  child: ListTile(
                    leading: Icon(
                      Icons.square_rounded,
                      color: colorMap[data.displayTitle],
                    ),
                    title: Text(
                      data.displayTitle,
                      style: GoogleFonts.openSans(
                        fontSize: 14, 
                        color: Color(0xFF173F70),
                      ),
                    ),
                    trailing: Text(
                      '${data.displayCount} events',
                      style: GoogleFonts.openSans(
                        fontSize: 14, 
                        color: Color(0xFF173F70),
                      ),
                    ),
                  ),
                );
              }
            },
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
