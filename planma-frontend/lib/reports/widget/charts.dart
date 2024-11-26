import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:planma_app/reports/widget/class.dart';

class TaskCharts extends StatelessWidget {
  final bool isLoading;
  final List<TaskTimeSpent> taskTimeSpent;
  final List<TaskTimeDistribution> taskTimeDistribution;
  final List<FinishedTask> taskFinished;

  const TaskCharts({
    Key? key,
    required this.isLoading,
    required this.taskTimeSpent,
    required this.taskTimeDistribution,
    required this.taskFinished,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Time Spent on Tasks Chart
        ChartContainer(
          title: 'Time Spent on Tasks',
          isLoading: isLoading,
          child: SfCartesianChart(
            primaryXAxis: CategoryAxis(),
            primaryYAxis: NumericAxis(
              title: AxisTitle(text: 'Minutes'),
              minimum: 0,
              maximum: 50,
              interval: 10,
            ),
            series: <CartesianSeries>[
              ColumnSeries<TaskTimeSpent, String>(
                dataSource: taskTimeSpent,
                xValueMapper: (TaskTimeSpent data, _) => data.day,
                yValueMapper: (TaskTimeSpent data, _) => data.minutes,
                color: Colors.blueGrey,
                name: 'Time Spent',
              ),
            ],
            legend: Legend(
              isVisible: true,
              position: LegendPosition.bottom,
              alignment: ChartAlignment.center,
              orientation: LegendItemOrientation.horizontal,
              iconHeight: 15,
              iconWidth: 15,
              textStyle: TextStyle(fontSize: 14, color: Colors.black),
            ),
          ),
        ),
        SizedBox(height: 16),

        // Task Time Distribution Chart
        ChartContainer(
          title: 'Task Time Distribution',
          isLoading: isLoading,
          child: SfCircularChart(
            series: <CircularSeries>[
              DoughnutSeries<TaskTimeDistribution, String>(
                dataSource: taskTimeDistribution,
                xValueMapper: (TaskTimeDistribution data, _) => data.taskName,
                yValueMapper: (TaskTimeDistribution data, _) => data.percentage,
                pointColorMapper: (TaskTimeDistribution data, _) => data.color,
                name: 'Task Time',
                dataLabelSettings: DataLabelSettings(
                  isVisible: true,
                  labelPosition: ChartDataLabelPosition.outside,
                  connectorLineSettings:
                      ConnectorLineSettings(type: ConnectorType.curve),
                ),
              ),
            ],
            legend: Legend(
              isVisible: true,
              position: LegendPosition.bottom,
              alignment: ChartAlignment.center,
              orientation: LegendItemOrientation.vertical,
              iconHeight: 15,
              iconWidth: 15,
              textStyle: TextStyle(fontSize: 14, color: Colors.black),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Tasks Finished Chart
        ChartContainer(
          title: 'Tasks Finished',
          isLoading: isLoading,
          child: SfCartesianChart(
            primaryXAxis: CategoryAxis(),
            primaryYAxis: NumericAxis(title: AxisTitle(text: 'Tasks')),
            series: <CartesianSeries>[
              ColumnSeries<FinishedTask, String>(
                dataSource: taskFinished,
                xValueMapper: (FinishedTask data, _) => data.taskName,
                yValueMapper: (FinishedTask data, _) => data.count,
                color: Colors.blueGrey,
                name: 'Finished Tasks', // Set name for legend
              ),
            ],
            legend: Legend(
              isVisible: true,
              position: LegendPosition.bottom,
              alignment: ChartAlignment.center,
              orientation: LegendItemOrientation.horizontal,
              iconHeight: 15,
              iconWidth: 15,
              textStyle: TextStyle(fontSize: 14, color: Colors.black),
            ),
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
    Key? key,
    required this.isLoading,
    required this.eventAttendanceSummary,
    required this.eventTypeDistribution,
    required this.eventAttendanceDistribution,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ChartContainer(
          title: 'Attendance Summary',
          isLoading: isLoading,
          child: SfCircularChart(
            series: <CircularSeries>[
              DoughnutSeries<EventAttendancecSummary, String>(
                dataSource: eventAttendanceSummary,
                xValueMapper: (EventAttendancecSummary data, _) =>
                    data.attendance,
                yValueMapper: (EventAttendancecSummary data, _) =>
                    data.attendanceCount,
                pointColorMapper: (EventAttendancecSummary data, _) =>
                    data.color,
                dataLabelSettings: DataLabelSettings(
                  isVisible: true, // Display data labels on segments
                  labelPosition: ChartDataLabelPosition.outside,
                  connectorLineSettings:
                      ConnectorLineSettings(type: ConnectorType.curve),
                ),
              ),
            ],
            legend: Legend(
              isVisible: true,
              position: LegendPosition.bottom,
              itemPadding: 10,
              alignment: ChartAlignment.center,
              orientation: LegendItemOrientation.horizontal,
              iconHeight: 15,
              iconWidth: 15,
              textStyle: TextStyle(fontSize: 14, color: Colors.black),
            ),
          ),
        ),
        SizedBox(height: 16),

        // Event Time Distribution Chart
        ChartContainer(
          title: 'Event Type Distribution',
          isLoading: isLoading,
          child: SfCircularChart(
            series: <CircularSeries>[
              DoughnutSeries<EventTypeDistribution, String>(
                dataSource: eventTypeDistribution,
                xValueMapper: (EventTypeDistribution data, _) => data.eventType,
                yValueMapper: (EventTypeDistribution data, _) =>
                    data.attendanceCount,
                pointColorMapper: (EventTypeDistribution data, _) => data.color,
                dataLabelSettings: DataLabelSettings(
                  isVisible: true, // Display data labels on segments
                  labelPosition: ChartDataLabelPosition.outside,
                  connectorLineSettings:
                      ConnectorLineSettings(type: ConnectorType.curve),
                ),
              ),
            ],
            legend: Legend(
              isVisible: true,
              position: LegendPosition.bottom,
              itemPadding: 10,
              alignment: ChartAlignment.center,
              orientation: LegendItemOrientation.horizontal,
              iconHeight: 15,
              iconWidth: 15,
              textStyle: TextStyle(fontSize: 14, color: Colors.black),
            ),
          ),
        ),
        SizedBox(height: 16),

        // Attendance Distribution Chart
        ChartContainer(
          title: 'Attendance Distribution',
          isLoading: isLoading,
          child: SfCartesianChart(
            primaryXAxis: CategoryAxis(),
            primaryYAxis: NumericAxis(
              minimum: 0,
              maximum: 10,
              interval: 2,
              title: AxisTitle(text: 'Count'),
            ),
            legend: Legend(isVisible: true),
            tooltipBehavior: TooltipBehavior(enable: true),
            series: <CartesianSeries>[
              ColumnSeries<EventAttendanceDistribution, String>(
                name: 'Academic',
                dataSource: eventAttendanceDistribution,
                xValueMapper: (EventAttendanceDistribution data, _) =>
                    data.category,
                yValueMapper: (EventAttendanceDistribution data, _) =>
                    data.academicCount,
                color: Color(0xFF32C652),
                dataLabelSettings:
                    DataLabelSettings(isVisible: true), // Display data labels
              ),
              ColumnSeries<EventAttendanceDistribution, String>(
                name: 'Personal',
                dataSource: eventAttendanceDistribution,
                xValueMapper: (EventAttendanceDistribution data, _) =>
                    data.category,
                yValueMapper: (EventAttendanceDistribution data, _) =>
                    data.personalCount,
                color: Color(0xFFEF4738),
                dataLabelSettings:
                    DataLabelSettings(isVisible: true), // Display data labels
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
    Key? key,
    required this.isLoading,
    required this.classAttendanceSummary,
    required this.classAttendanceDistribution,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft, // Aligns the text to the start
          child: Text(
            'Class Schedules',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(height: 16),
        ChartContainer(
          title: 'Attendance Summary',
          isLoading: isLoading,
          child: SfCircularChart(
            series: <CircularSeries>[
              DoughnutSeries<ClassAttendanceSummary, String>(
                dataSource: classAttendanceSummary,
                xValueMapper: (ClassAttendanceSummary data, _) => data.category,
                yValueMapper: (ClassAttendanceSummary data, _) =>
                    data.percentage,
                pointColorMapper: (ClassAttendanceSummary data, _) =>
                    data.color,
                dataLabelSettings: const DataLabelSettings(
                  isVisible: true,
                  labelPosition: ChartDataLabelPosition.outside,
                  connectorLineSettings:
                      ConnectorLineSettings(type: ConnectorType.curve),
                ),
              )
            ],
            legend: Legend(
              isVisible: true,
              position: LegendPosition.bottom,
              itemPadding: 10,
              alignment: ChartAlignment.center,
              orientation: LegendItemOrientation.horizontal,
              iconHeight: 15,
              iconWidth: 15,
              textStyle: TextStyle(fontSize: 14, color: Colors.black),
            ),
          ),
        ),
        ChartContainer(
            title: 'Attendance Distribution',
            isLoading: isLoading,
            child: SfCartesianChart(
              primaryXAxis: CategoryAxis(),
              primaryYAxis: NumericAxis(
                minimum: 0,
                maximum: 6,
                interval: 2,
              ),
              legend: Legend(isVisible: true),
              tooltipBehavior: TooltipBehavior(enable: true),
              series: <CartesianSeries>[
                ColumnSeries<ClassAttendanceDistribution, String>(
                  name: 'Did Not Attend',
                  dataSource: classAttendanceDistribution,
                  xValueMapper: (ClassAttendanceDistribution data, _) =>
                      data.subject,
                  yValueMapper: (ClassAttendanceDistribution data, _) =>
                      data.didNotAttend,
                  color: Color(0xFFEF4738),
                ),
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
              ],
            ))
      ],
    );
  }
}

//------------------------------------------------------------------------------

class ActivitiesChart extends StatelessWidget {
  final bool isLoading;
  final List<ActivitiesTimeSpent> activitiesTimeSpent;
  final List<ActivitiesDone> activitiesDone;

  const ActivitiesChart({
    Key? key,
    required this.isLoading,
    required this.activitiesTimeSpent,
    required this.activitiesDone,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ChartContainer(
          title: 'Time Spent Distribution',
          isLoading: isLoading,
          child: SfCartesianChart(
            primaryXAxis: CategoryAxis(),
            primaryYAxis: NumericAxis(minimum: 0, maximum: 50, interval: 10),
            series: <CartesianSeries>[
              ColumnSeries<ActivitiesTimeSpent, String>(
                dataSource: activitiesTimeSpent,
                xValueMapper: (ActivitiesTimeSpent data, _) => data.day,
                yValueMapper: (ActivitiesTimeSpent data, _) => data.minutes,
                color: Color(0xFF537488),
              )
            ],
          ),
        ),
        SizedBox(height: 16),
        ChartContainer(
          title: 'Activities Done',
          isLoading: isLoading,
          child: SfCartesianChart(
            primaryXAxis: CategoryAxis(),
            primaryYAxis: NumericAxis(minimum: 0, maximum: 10, interval: 2),
            series: <CartesianSeries>[
              ColumnSeries<ActivitiesDone, String>(
                dataSource: activitiesDone,
                xValueMapper: (ActivitiesDone data, _) => data.day,
                yValueMapper: (ActivitiesDone data, _) => data.numTask,
                color: Color(0xFF537488),
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
  final List<GoalTimeSpent> goalTimeSpent;

  const GoalsCharts(
      {Key? key, required this.isLoading, required this.goalTimeSpent})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ChartContainer(
          title: 'Time Spent Distribution',
          isLoading: isLoading,
          child: SfCartesianChart(
            primaryXAxis: CategoryAxis(),
            primaryYAxis: NumericAxis(
              minimum: 0,
              maximum: 50,
              interval: 10,
            ),
            series: <CartesianSeries>[
              ColumnSeries<GoalTimeSpent, String>(
                dataSource: goalTimeSpent,
                xValueMapper: (GoalTimeSpent data, _) => data.day,
                yValueMapper: (GoalTimeSpent data, _) => data.minutes,
                color: Colors.blueGrey,
                name: 'Time Spent',
              ),
            ],
            legend: Legend(
              isVisible: true,
              position: LegendPosition.bottom,
              alignment: ChartAlignment.center,
              orientation: LegendItemOrientation.horizontal,
              iconHeight: 15,
              iconWidth: 15,
              textStyle: TextStyle(fontSize: 14, color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }
}

class SleepCharts extends StatelessWidget {
  final bool isLoading;
  final List<SleepDuration> sleepDuration;

  SleepCharts({Key? key, required this.isLoading, required this.sleepDuration})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ChartContainer(
          title: 'Sleep Duration',
          isLoading: isLoading,
          child: SfCartesianChart(
            primaryXAxis: CategoryAxis(),
            primaryYAxis: NumericAxis(
              minimum: 0,
              maximum: 10,
              interval: 2,
            ),
            series: <CartesianSeries>[
              ColumnSeries<SleepDuration, String>(
                dataSource: sleepDuration,
                xValueMapper: (SleepDuration data, _) => data.day,
                yValueMapper: (SleepDuration data, _) => data.hours,
                color: Color(0xFF537488),
                name: 'Time Spent',
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        ChartContainer(
          title: 'Sleep Regularly',
          isLoading: isLoading,
          child: SfCartesianChart(
            plotAreaBorderWidth: 0,
            primaryXAxis: CategoryAxis(
              labelStyle: const TextStyle(
                fontSize: 12,
              ),
              majorGridLines: const MajorGridLines(width: 0),
            ),
            primaryYAxis: NumericAxis(
              labelFormat: '{value}:00',
              minimum: 0,
              maximum: 24,
              interval: 4,
              majorGridLines: const MajorGridLines(width: 0.5),
              axisLine: const AxisLine(width: 0),
            ),
            series: <CartesianSeries>[
              ColumnSeries<SleepDuration, String>(
                dataSource: sleepDuration,
                xValueMapper: (SleepDuration data, _) => data.day,
                yValueMapper: (SleepDuration data, _) => data.hours,
                borderRadius: const BorderRadius.all(Radius.circular(4)),
                width: 0.5,
                color: Colors.blueGrey,
              )
            ],
          ),
        ),
      ],
    );
  }
}
