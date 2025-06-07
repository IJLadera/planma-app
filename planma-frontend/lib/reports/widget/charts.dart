import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:planma_app/models/sleep_log_model.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:planma_app/reports/widget/class.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

class TaskCharts extends StatelessWidget {
  final bool isLoading;
  final String timeFilter;
  final DateTime selectedDate;
  final List<TaskTimeSpent> taskTimeSpent;
  final List<TaskTimeDistribution> taskTimeDistribution;
  final List<FinishedTask> taskFinished;

  const TaskCharts({
    super.key,
    required this.isLoading,
    required this.timeFilter,
    required this.selectedDate,
    required this.taskTimeSpent,
    required this.taskTimeDistribution,
    required this.taskFinished,
  });

  List<String> generateXAxisLabels() {
    // DateTime now = DateTime.now();
    switch (timeFilter) {
      case 'Day':
        return [DateFormat('yyyy-MM-dd').format(selectedDate)];
      case 'Week':
        return List.generate(7, (index) {
          DateTime day = selectedDate
              .subtract(Duration(days: selectedDate.weekday - 1))
              .add(Duration(days: index));
          return DateFormat('EEE').format(day);
        });
      case 'Month':
        int daysInMonth =
            DateTime(selectedDate.year, selectedDate.month + 1, 0).day;
        return List.generate(
            daysInMonth, (index) => (index + 1).toString().padLeft(2, '0'));
      case 'Semester':
        return ['H1', 'H2']; // Adjust based on semester
      case 'Year':
        return [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec'
        ];
      default:
        return [];
    }
  }

  List<TaskTimeSpent> fillMissingData(List<String> labels) {
    Map<String, TaskTimeSpent> mappedData = {
      for (var item in taskTimeSpent) item.day: item
    };

    double totalTimeSpent =
        taskTimeSpent.isNotEmpty ? taskTimeSpent.first.totalTimeSpent : 0;

    return labels.map((label) {
      return mappedData[label] ?? TaskTimeSpent(label, 0, totalTimeSpent);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    List<String> xAxisLabels = generateXAxisLabels();
    List<TaskTimeSpent> filledData = fillMissingData(xAxisLabels);

    return Column(
      children: [
        // Time Spent on Tasks Chart
        ChartContainer2(
          title: 'Time Spent Distribution',
          isLoading: isLoading,
          subtitle: "Total Time Spent:",
          subtitleValue:
              "${filledData.isNotEmpty ? filledData.first.totalTimeSpent : 0} mins",
          child: SfCartesianChart(
            primaryXAxis: CategoryAxis(
              labelPlacement: LabelPlacement.betweenTicks,
              labelAlignment: LabelAlignment.center,
              majorGridLines: const MajorGridLines(width: 0),
              interval: 1,
              labelStyle: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w400,
              ),
            ),
            primaryYAxis: NumericAxis(
              // title: AxisTitle(text: 'Minutes'),
              labelStyle: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w400,
              ),
              minimum: 0,
              maximum: filledData
                      .map((e) => e.minutes)
                      .reduce((a, b) => a > b ? a : b) +
                  10,
            ),
            series: <CartesianSeries<TaskTimeSpent, String>>[
              ColumnSeries<TaskTimeSpent, String>(
                dataSource: filledData,
                xValueMapper: (TaskTimeSpent data, _) => data.day,
                yValueMapper: (TaskTimeSpent data, _) => data.minutes,
                color: Colors.blueGrey,
              ),
            ],
          ),
        ),
        SizedBox(height: 16),

        // Task Time Distribution Chart
        ChartContainer3(
          title: 'Task Time Distribution',
          isLoading: isLoading,
          list: taskTimeDistribution,
          child: SfCircularChart(
            margin: EdgeInsets.zero,
            palette: <Color>[
              Colors.red.shade400,
              Colors.blue,
              Colors.green.shade400,
              Colors.amber,
              Colors.purpleAccent,
              Colors.indigo,
              Colors.orange
            ],
            series: <CircularSeries>[
              DoughnutSeries<TaskTimeDistribution, String>(
                dataSource: taskTimeDistribution.isNotEmpty
                    ? taskTimeDistribution
                    : [TaskTimeDistribution("No Data", 1)],
                xValueMapper: (TaskTimeDistribution data, _) => data.subName,
                yValueMapper: (TaskTimeDistribution data, _) => data.percentage,
                explodeAll: true,
                pointColorMapper: (TaskTimeDistribution data, _) =>
                    data.subName == "No Data" ? Colors.grey.shade300 : null,
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Tasks Finished Chart
        ChartContainer2(
          title: 'Tasks Finished',
          isLoading: isLoading,
          subtitle: "Total Tasks Finished:",
          subtitleValue:
              "${taskFinished.isNotEmpty ? taskFinished.first.totalTaskFinished : 0} tasks",
          child: SfCartesianChart(
            primaryXAxis: CategoryAxis(
              labelPlacement: LabelPlacement.betweenTicks,
              labelAlignment: LabelAlignment.center,
              majorGridLines: const MajorGridLines(width: 0),
              interval: 1,
              labelStyle: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w400,
              ),
            ),
            primaryYAxis: NumericAxis(
              labelStyle: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w400,
              ),
              minimum: 0,
              maximum: (taskFinished.isNotEmpty) ? null : 2,
              interval:
                  (taskFinished.isNotEmpty && taskFinished.length > 10) ? 5 : 1,
            ),
            series: <CartesianSeries>[
              ColumnSeries<FinishedTask, String>(
                dataSource: taskFinished,
                xValueMapper: (FinishedTask data, _) => data.subName,
                yValueMapper: (FinishedTask data, _) => data.count,
                color: Colors.blueGrey,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

//--------------------------------------------------------------------------

class EventCharts extends StatelessWidget {
  final bool isLoading;
  final List<EventAttendancecSummary> eventAttendanceSummary;
  final List<EventTypeDistribution> eventTypeDistribution;
  final List<EventAttendanceDistribution> eventAttendanceDistribution;

  const EventCharts({
    super.key,
    required this.isLoading,
    required this.eventAttendanceSummary,
    required this.eventTypeDistribution,
    required this.eventAttendanceDistribution,
  });

  @override
  Widget build(BuildContext context) {
    final Map<String, Color> colorMap1 = {
      "Attended": Colors.green.shade400,
      "Did Not Attend": Colors.red.shade400,
      "No Data": Colors.grey.shade300,
    };

    final Map<String, Color> colorMap2 = {
      "Academic": Color(0xFFFBC62F),
      "Personal": Color(0xFF00C7F2),
      "No Data": Colors.grey.shade300,
    };

    return Column(
      children: [
        ChartContainer4(
          title: 'Attendance Summary',
          isLoading: isLoading,
          list: eventAttendanceSummary,
          colorMap: colorMap1,
          child: SfCircularChart(
            margin: EdgeInsets.zero,
            series: <CircularSeries>[
              PieSeries<EventAttendancecSummary, String>(
                dataSource: eventAttendanceSummary.isNotEmpty
                    ? eventAttendanceSummary
                    : [EventAttendancecSummary("No Data", 1)],
                xValueMapper: (EventAttendancecSummary data, _) =>
                    data.attendance,
                yValueMapper: (EventAttendancecSummary data, _) =>
                    data.attendanceCount,
                pointColorMapper: (EventAttendancecSummary data, _) =>
                    colorMap1[data.attendance],
              ),
            ],
          ),
        ),
        SizedBox(height: 16),

        // Event Time Distribution Chart
        ChartContainer4(
          title: 'Event Type Distribution',
          isLoading: isLoading,
          list: eventTypeDistribution,
          colorMap: colorMap2,
          child: SfCircularChart(
            margin: EdgeInsets.only(),
            series: <CircularSeries>[
              PieSeries<EventTypeDistribution, String>(
                dataSource: eventTypeDistribution.isNotEmpty
                    ? eventTypeDistribution
                    : [EventTypeDistribution("No Data", 1)],
                xValueMapper: (EventTypeDistribution data, _) => data.eventType,
                yValueMapper: (EventTypeDistribution data, _) =>
                    data.attendanceCount,
                pointColorMapper: (EventTypeDistribution data, _) =>
                    colorMap2[data.eventType],
              ),
            ],
          ),
        ),
        SizedBox(height: 16),

        // Attendance Distribution Chart
        ChartContainer(
          title: 'Attendance Distribution',
          isLoading: isLoading,
          child: SfCartesianChart(
            primaryXAxis: CategoryAxis(
              labelPlacement: LabelPlacement.betweenTicks,
              labelAlignment: LabelAlignment.center,
              majorGridLines: const MajorGridLines(width: 0),
              interval: 1,
              labelStyle: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w400,
              ),
            ),
            primaryYAxis: NumericAxis(
              labelStyle: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w400,
              ),
              minimum: 0,
              maximum: (eventAttendanceDistribution.isNotEmpty) ? null : 2,
              interval: eventAttendanceDistribution.isNotEmpty &&
                      eventAttendanceDistribution
                              .map((e) => e.attendedCount > e.didNotAttendCount
                                  ? e.attendedCount
                                  : e.didNotAttendCount)
                              .reduce((a, b) => a > b ? a : b) >
                          10
                  ? 5
                  : 1,
            ),
            legend: Legend(
              isVisible: true,
              position: LegendPosition.bottom,
              textStyle: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w400,
              ),
            ),
            series: <CartesianSeries>[
              ColumnSeries<EventAttendanceDistribution, String>(
                name: 'Attended',
                dataSource: eventAttendanceDistribution,
                xValueMapper: (EventAttendanceDistribution data, _) =>
                    data.category,
                yValueMapper: (EventAttendanceDistribution data, _) =>
                    data.attendedCount,
                color: Color(0xFF32C652),
              ),
              ColumnSeries<EventAttendanceDistribution, String>(
                name: 'Did Not Attend',
                dataSource: eventAttendanceDistribution,
                xValueMapper: (EventAttendanceDistribution data, _) =>
                    data.category,
                yValueMapper: (EventAttendanceDistribution data, _) =>
                    data.didNotAttendCount,
                color: Color(0xFFEF4738),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

//-----------------------------------------------------------------------------

class ClassScheduleCharts extends StatelessWidget {
  final bool isLoading;
  final List<ClassAttendanceSummary> classAttendanceSummary;
  final List<ClassAttendanceDistribution> classAttendanceDistribution;

  const ClassScheduleCharts({
    super.key,
    required this.isLoading,
    required this.classAttendanceSummary,
    required this.classAttendanceDistribution,
  });

  @override
  Widget build(BuildContext context) {
    final Map<String, Color> colorMap = {
      "Attended": Colors.green.shade400,
      "Excused": Colors.blue.shade600,
      "Did Not Attend": Colors.red.shade400,
      "No Data": Colors.grey.shade300,
    };

    return Column(
      children: [
        // Class Attendance Summary Chart
        ChartContainer4(
          title: 'Attendance Summary',
          isLoading: isLoading,
          list: classAttendanceSummary,
          colorMap: colorMap,
          child: SfCircularChart(
            margin: EdgeInsets.zero,
            series: <CircularSeries>[
              PieSeries<ClassAttendanceSummary, String>(
                dataSource: classAttendanceSummary.isNotEmpty
                    ? classAttendanceSummary
                    : [ClassAttendanceSummary("No Data", 1)],
                xValueMapper: (ClassAttendanceSummary data, _) => data.category,
                yValueMapper: (ClassAttendanceSummary data, _) => data.count,
                pointColorMapper: (ClassAttendanceSummary data, _) =>
                    colorMap[data.category],
              )
            ],
          ),
        ),
        SizedBox(height: 16),

        // Class Attendance Distribution
        ChartContainer(
          title: 'Attendance Distribution',
          isLoading: isLoading,
          child: SfCartesianChart(
            primaryXAxis: CategoryAxis(
              labelPlacement: LabelPlacement.betweenTicks,
              labelAlignment: LabelAlignment.center,
              majorGridLines: const MajorGridLines(width: 0),
              interval: 1,
              labelStyle: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w400,
              ),
            ),
            primaryYAxis: NumericAxis(
              labelStyle: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w400,
              ),
              minimum: 0,
              maximum: (classAttendanceDistribution.isNotEmpty) ? null : 2,
              interval: classAttendanceDistribution.isNotEmpty &&
                      classAttendanceDistribution
                              .map((e) => [
                                    e.attended,
                                    e.excused,
                                    e.didNotAttend
                                  ].reduce((a, b) => a > b ? a : b))
                              .reduce((a, b) => a > b ? a : b) >
                          10
                  ? 5
                  : 1,
            ),
            legend: Legend(
              isVisible: true,
              position: LegendPosition.bottom,
              textStyle: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w400,
              ),
            ),
            series: <CartesianSeries>[
              ColumnSeries<ClassAttendanceDistribution, String>(
                name: 'Attended',
                dataSource: classAttendanceDistribution,
                xValueMapper: (ClassAttendanceDistribution data, _) =>
                    data.subject,
                yValueMapper: (ClassAttendanceDistribution data, _) =>
                    data.attended,
                color: Color(0xFF32C652),
              ),
              ColumnSeries<ClassAttendanceDistribution, String>(
                name: 'Excused',
                dataSource: classAttendanceDistribution,
                xValueMapper: (ClassAttendanceDistribution data, _) =>
                    data.subject,
                yValueMapper: (ClassAttendanceDistribution data, _) =>
                    data.excused,
                color: Color(0xFF3A82EF),
              ),
              ColumnSeries<ClassAttendanceDistribution, String>(
                name: 'Did Not Attend',
                dataSource: classAttendanceDistribution,
                xValueMapper: (ClassAttendanceDistribution data, _) =>
                    data.subject,
                yValueMapper: (ClassAttendanceDistribution data, _) =>
                    data.didNotAttend,
                color: Color(0xFFEF4738),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

//------------------------------------------------------------------------------

class ActivitiesChart extends StatelessWidget {
  final bool isLoading;
  final String timeFilter;
  final DateTime selectedDate;
  final List<ActivitiesTimeSpent> activitiesTimeSpent;
  final List<ActivitiesDone> activitiesDone;

  const ActivitiesChart({
    super.key,
    required this.isLoading,
    required this.timeFilter,
    required this.selectedDate,
    required this.activitiesTimeSpent,
    required this.activitiesDone,
  });

  List<String> generateXAxisLabels() {
    // DateTime now = DateTime.now();
    switch (timeFilter) {
      case 'Day':
        return [DateFormat('yyyy-MM-dd').format(selectedDate)];
      case 'Week':
        return List.generate(7, (index) {
          DateTime day = selectedDate
              .subtract(Duration(days: selectedDate.weekday - 1))
              .add(Duration(days: index));
          return DateFormat('EEE').format(day);
        });
      case 'Month':
        int daysInMonth =
            DateTime(selectedDate.year, selectedDate.month + 1, 0).day;
        return List.generate(
            daysInMonth, (index) => (index + 1).toString().padLeft(2, '0'));
      case 'Semester':
        return ['H1', 'H2']; // Adjust based on semester
      case 'Year':
        return [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec'
        ];
      default:
        return [];
    }
  }

  List<ActivitiesTimeSpent> fillMissingData1(List<String> labels) {
    Map<String, ActivitiesTimeSpent> mappedData = {
      for (var item in activitiesTimeSpent) item.day: item
    };

    double totalTimeSpent = activitiesTimeSpent.isNotEmpty
        ? activitiesTimeSpent.first.totalTimeSpent
        : 0;

    return labels.map((label) {
      return mappedData[label] ?? ActivitiesTimeSpent(label, 0, totalTimeSpent);
    }).toList();
  }

  List<ActivitiesDone> fillMissingData2(List<String> labels) {
    Map<String, ActivitiesDone> mappedData = {
      for (var item in activitiesDone) item.day: item
    };

    int totalCount =
        activitiesDone.isNotEmpty ? activitiesDone.first.totalActivityDone : 0;

    return labels.map((label) {
      return mappedData[label] ?? ActivitiesDone(label, 0, totalCount);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    List<String> xAxisLabels = generateXAxisLabels();
    List<ActivitiesTimeSpent> filledData1 = fillMissingData1(xAxisLabels);
    List<ActivitiesDone> filledData2 = fillMissingData2(xAxisLabels);

    return Column(
      children: [
        // Time Spent on Activities Chart
        ChartContainer2(
          title: 'Time Spent Distribution',
          isLoading: isLoading,
          subtitle: "Total Time Spent:",
          subtitleValue:
              "${filledData1.isNotEmpty ? filledData1.first.totalTimeSpent : 0} mins",
          child: SfCartesianChart(
            primaryXAxis: CategoryAxis(
              labelPlacement: LabelPlacement.betweenTicks,
              labelAlignment: LabelAlignment.center,
              majorGridLines: const MajorGridLines(width: 0),
              interval: 1,
              labelStyle: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w400,
              ),
            ),
            primaryYAxis: NumericAxis(
              labelStyle: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w400,
              ),
              minimum: 0,
              maximum: filledData1
                      .map((e) => e.minutes)
                      .reduce((a, b) => a > b ? a : b) +
                  10,
            ),
            series: <CartesianSeries>[
              ColumnSeries<ActivitiesTimeSpent, String>(
                dataSource: filledData1,
                xValueMapper: (ActivitiesTimeSpent data, _) => data.day,
                yValueMapper: (ActivitiesTimeSpent data, _) => data.minutes,
                color: Colors.blueGrey,
              )
            ],
          ),
        ),
        SizedBox(height: 16),

        // Activities Done Chart
        ChartContainer2(
          title: 'Activities Done',
          isLoading: isLoading,
          subtitle: "Total Activities Done:",
          subtitleValue:
              "${filledData2.isNotEmpty ? filledData2.first.totalActivityDone : 0} activities",
          child: SfCartesianChart(
            primaryXAxis: CategoryAxis(
              labelPlacement: LabelPlacement.betweenTicks,
              labelAlignment: LabelAlignment.center,
              majorGridLines: const MajorGridLines(width: 0),
              interval: 1,
              labelStyle: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w400,
              ),
            ),
            primaryYAxis: NumericAxis(
              labelStyle: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w400,
              ),
              minimum: 0,
              maximum: (filledData2.isNotEmpty) ? null : 2,
              interval: (filledData2.isNotEmpty &&
                      filledData2
                              .map((e) => e.numTask)
                              .reduce((a, b) => a > b ? a : b) >
                          10)
                  ? 5
                  : 1,
            ),
            series: <CartesianSeries>[
              ColumnSeries<ActivitiesDone, String>(
                dataSource: filledData2,
                xValueMapper: (ActivitiesDone data, _) => data.day,
                yValueMapper: (ActivitiesDone data, _) => data.numTask,
                color: Colors.blueGrey,
              )
            ],
          ),
        ),
      ],
    );
  }
}

class GoalsCharts extends StatelessWidget {
  final bool isLoading;
  final String timeFilter;
  final DateTime selectedDate;
  final List<GoalTimeSpent> goalTimeSpent;
  final List<GoalTimeDistribution> goalTimeDistribution;
  final List<GoalCompletionCount> goalCompletionCount;

  const GoalsCharts({
    super.key,
    required this.isLoading,
    required this.timeFilter,
    required this.selectedDate,
    required this.goalTimeSpent,
    required this.goalTimeDistribution,
    required this.goalCompletionCount,
  });

  List<String> generateXAxisLabels() {
    // DateTime now = DateTime.now();
    switch (timeFilter) {
      case 'Day':
        return [DateFormat('yyyy-MM-dd').format(selectedDate)];
      case 'Week':
        return List.generate(7, (index) {
          DateTime day = selectedDate
              .subtract(Duration(days: selectedDate.weekday - 1))
              .add(Duration(days: index));
          return DateFormat('EEE').format(day);
        });
      case 'Month':
        int daysInMonth =
            DateTime(selectedDate.year, selectedDate.month + 1, 0).day;
        return List.generate(
            daysInMonth, (index) => (index + 1).toString().padLeft(2, '0'));
      case 'Semester':
        return ['H1', 'H2']; // Adjust based on semester
      case 'Year':
        return [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec'
        ];
      default:
        return [];
    }
  }

  List<GoalTimeSpent> fillMissingData(List<String> labels) {
    Map<String, GoalTimeSpent> mappedData = {
      for (var item in goalTimeSpent) item.day: item
    };

    double totalTimeSpent =
        goalTimeSpent.isNotEmpty ? goalTimeSpent.first.totalTimeSpent : 0;

    return labels.map((label) {
      return mappedData[label] ?? GoalTimeSpent(label, 0, totalTimeSpent);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    List<String> xAxisLabels = generateXAxisLabels();
    List<GoalTimeSpent> filledData = fillMissingData(xAxisLabels);

    final Map<String, Color> colorMap = {
      "Academic": Color(0xFFFBC62F),
      "Personal": Color(0xFF00C7F2),
      "No Data": Colors.grey.shade300,
    };

    return Column(
      children: [
        ChartContainer2(
          title: 'Time Spent Distribution',
          isLoading: isLoading,
          subtitle: "Total Time Spent:",
          subtitleValue: "No logic yet",
          child: SfCartesianChart(
            primaryXAxis: CategoryAxis(
              labelPlacement: LabelPlacement.betweenTicks,
              labelAlignment: LabelAlignment.center,
              majorGridLines: const MajorGridLines(width: 0),
              interval: 1,
              labelStyle: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w400,
              ),
            ),
            primaryYAxis: NumericAxis(
              labelStyle: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w400,
              ),
              minimum: 0,
              maximum: filledData
                      .map((e) => e.minutes)
                      .reduce((a, b) => a > b ? a : b) +
                  10,
            ),
            series: <CartesianSeries>[
              ColumnSeries<GoalTimeSpent, String>(
                dataSource: filledData,
                xValueMapper: (GoalTimeSpent data, _) => data.day,
                yValueMapper: (GoalTimeSpent data, _) => data.minutes,
                color: Colors.blueGrey,
              ),
            ],
          ),
        ),
        SizedBox(height: 16),

        // Goal Time Distribution Chart
        ChartContainer5(
          title: 'Goal Time Distribution',
          isLoading: isLoading,
          list: goalTimeDistribution,
          colorMap: colorMap,
          child: SfCircularChart(
            margin: EdgeInsets.zero,
            series: <CircularSeries>[
              DoughnutSeries<GoalTimeDistribution, String>(
                dataSource: goalTimeDistribution.isNotEmpty
                    ? goalTimeDistribution
                    : [GoalTimeDistribution("No Data", 1)],
                xValueMapper: (GoalTimeDistribution data, _) => data.goalType,
                yValueMapper: (GoalTimeDistribution data, _) => data.percentage,
                explodeAll: true,
                pointColorMapper: (GoalTimeDistribution data, _) =>
                    data.goalType == "No Data" ? Colors.grey.shade300 : null,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Goal Completion Count Chart
        ChartContainer(
          title: 'Goal Completion Count',
          isLoading: isLoading,
          child: SfCartesianChart(
            primaryXAxis: CategoryAxis(
              labelPlacement: LabelPlacement.betweenTicks,
              labelAlignment: LabelAlignment.center,
              majorGridLines: const MajorGridLines(width: 0),
              interval: 1,
              labelStyle: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w400,
              ),
            ),
            primaryYAxis: NumericAxis(
              labelStyle: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w400,
              ),
              minimum: 0,
              maximum: (goalCompletionCount.isNotEmpty) ? null : 2,
              interval: goalCompletionCount.isNotEmpty &&
                      goalCompletionCount
                              .map((e) => e.completedCount > e.failedCount
                                  ? e.completedCount
                                  : e.failedCount)
                              .reduce((a, b) => a > b ? a : b) >
                          10
                  ? 5
                  : 1,
            ),
            legend: Legend(
              isVisible: true,
              position: LegendPosition.bottom,
              textStyle: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w400,
              ),
            ),
            series: <CartesianSeries>[
              ColumnSeries<GoalCompletionCount, String>(
                name: 'Completed',
                dataSource: goalCompletionCount,
                xValueMapper: (GoalCompletionCount data, _) => data.goal,
                yValueMapper: (GoalCompletionCount data, _) =>
                    data.completedCount,
                color: Color(0xFF32C652),
              ),
              ColumnSeries<GoalCompletionCount, String>(
                name: 'Failed',
                dataSource: goalCompletionCount,
                xValueMapper: (GoalCompletionCount data, _) => data.goal,
                yValueMapper: (GoalCompletionCount data, _) => data.failedCount,
                color: Color(0xFFEF4738),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SleepCharts extends StatelessWidget {
  final bool isLoading;
  final String timeFilter;
  final DateTime selectedDate;
  final List<SleepDuration> sleepDuration;
  final List<SleepRegularity> sleepRegularity;

  const SleepCharts({
    super.key,
    required this.isLoading,
    required this.timeFilter,
    required this.selectedDate,
    required this.sleepDuration,
    required this.sleepRegularity,
  });

  List<String> generateXAxisLabels() {
    // DateTime now = DateTime.now();
    switch (timeFilter) {
      case 'Day':
        return [DateFormat('yyyy-MM-dd').format(selectedDate)];
      case 'Week':
        return List.generate(7, (index) {
          DateTime day = selectedDate
              .subtract(Duration(days: selectedDate.weekday - 1))
              .add(Duration(days: index));
          return DateFormat('EEE').format(day);
        });
      case 'Month':
        int daysInMonth =
            DateTime(selectedDate.year, selectedDate.month + 1, 0).day;
        return List.generate(
            daysInMonth, (index) => (index + 1).toString().padLeft(2, '0'));
      case 'Semester':
        return ['H1', 'H2']; // Adjust based on semester
      case 'Year':
        return [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec'
        ];
      default:
        return [];
    }
  }

  List<SleepDuration> fillMissingData(List<String> labels) {
    Map<String, SleepDuration> mappedData = {
      for (var item in sleepDuration) item.day: item
    };

    double averageHours =
        sleepDuration.isNotEmpty ? sleepDuration.first.averageHours : 0;

    return labels.map((label) {
      return mappedData[label] ?? SleepDuration(label, 0, averageHours);
    }).toList();
  }

  // TimeOfDay parseTimeOfDay(String timeString) {
  //   final parts = timeString.split(':').map(int.parse).toList();
  //   return TimeOfDay(hour: parts[0], minute: parts[1]);
  // }

  // int minutesSince6PM(String timeString) {
  //   final time = parseTimeOfDay(timeString);
  //   int minutes = time.hour * 60 + time.minute;
  //   int base = 18 * 60; // 6:00 PM
  //   return (minutes >= base) ? (minutes - base) : (minutes + (24 * 60 - base));
  // }

  // String formatMinutesToTime(int value) {
  //   int base = 18 * 60;
  //   int total = (value + base) % 1440;
  //   int hour = total ~/ 60;
  //   int minute = total % 60;
  //   return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  // }

  @override
  Widget build(BuildContext context) {
    List<String> xAxisLabels = generateXAxisLabels();
    List<SleepDuration> filledData = fillMissingData(xAxisLabels);

    double? minY;
    double? maxY;

    if (sleepRegularity.isNotEmpty) {
      final allMinutes = sleepRegularity
          .expand((log) => [log.startTime, log.endTime])
          .toList();

      minY = (allMinutes.reduce(min) ~/ 60) * 60;
      maxY = ((allMinutes.reduce(max) + 59) ~/ 60) * 60;
    }

    return Column(
      children: [
        // Sleep Duration Chart
        ChartContainer2(
          title: 'Sleep Duration',
          isLoading: isLoading,
          subtitle: "Average Sleep Duration",
          subtitleValue:
              "${filledData.isNotEmpty ? filledData.first.averageHours : 0} hours",
          child: SfCartesianChart(
            primaryXAxis: CategoryAxis(
              labelPlacement: LabelPlacement.betweenTicks,
              labelAlignment: LabelAlignment.center,
              majorGridLines: const MajorGridLines(width: 0),
              interval: 1,
              labelStyle: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w400,
              ),
            ),
            primaryYAxis: NumericAxis(
              labelStyle: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w400,
              ),
              minimum: 0,
              maximum: (filledData.isNotEmpty) ? null : 2,
            ),
            series: <CartesianSeries>[
              ColumnSeries<SleepDuration, String>(
                dataSource: filledData,
                xValueMapper: (SleepDuration data, _) => data.day,
                yValueMapper: (SleepDuration data, _) => data.hours,
                color: Colors.blueGrey,
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        ChartContainer(
          title: 'Sleep Regularity',
          isLoading: isLoading,
          child: SfCartesianChart(
            plotAreaBorderWidth: 0,
            primaryXAxis: CategoryAxis(
              majorGridLines: const MajorGridLines(width: 0),
              labelStyle: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w400,
              ),
            ),
            primaryYAxis: NumericAxis(
              labelStyle: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w400,
              ),
              minimum: minY ?? 0,
              maximum: maxY ?? 720,
              interval: 60,
              axisLabelFormatter: (AxisLabelRenderDetails args) {
                final hour = (args.value.toInt() ~/ 60 + 18) % 24;
                final minute = args.value.toInt() % 60;
                final formatted = "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}";
                return ChartAxisLabel(formatted, const TextStyle(fontSize: 12));
              },
            ),
            series: <CartesianSeries>[
              RangeColumnSeries<SleepRegularity, String>(
                dataSource: sleepRegularity,
                xValueMapper: (SleepRegularity data, _) => data.day,
                lowValueMapper: (SleepRegularity data, _) => data.startTime,
                highValueMapper: (SleepRegularity data, _) => data.endTime,
                color: Colors.blueGrey,
              )
            ],
          ),
        )
      ],
    );
  }

  /// Wraps time so that values from midnight (0:00 to 8:00) are displayed correctly.
  double _wrapTime(double time) {
    return (time < 20) ? time + 24 : time;
  }
}
