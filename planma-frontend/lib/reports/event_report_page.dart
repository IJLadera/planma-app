import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:planma_app/reports/widget/bottom_sheet.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class EventReportsPage extends StatefulWidget {
  const EventReportsPage({Key? key}) : super(key: key);

  @override
  State<EventReportsPage> createState() => _EventReportsPageState();
}

class _EventReportsPageState extends State<EventReportsPage> {
  String selectedTimeFilter = 'Day'; // Default filter
  String formattedTimeFilter = '';
  DateTime selectedDate = DateTime.now();
  bool isLoading = true;

  // Placeholder for chart data
  List<ChartData> timeSpent = [];
  List<TaskData> timeDistribution = [];
  List<FinishedTask> taskFinished = [];

  @override
  void initState() {
    super.initState();
    _updateFormattedTimeFilter();
    _fetchChartData();
  }

  void _updateFormattedTimeFilter() {
    DateTime today = DateTime.now();
    DateTime startOfWeek =
        today.subtract(Duration(days: today.weekday - 1)); // Start of the week
    DateTime endOfWeek =
        startOfWeek.add(const Duration(days: 6)); // End of the week

    switch (selectedTimeFilter) {
      case 'Week':
        formattedTimeFilter =
            '${DateFormat('yyyy-MM-dd').format(startOfWeek)} - ${DateFormat('yyyy-MM-dd').format(endOfWeek)}';
        selectedDate = startOfWeek;
        break;
      case 'Month':
      case 'Year':
      case 'Semester':
        formattedTimeFilter =
            DateFormat(selectedTimeFilter == 'Semester' ? 'MMMM yyyy' : 'yyyy')
                .format(today);
        selectedDate = today;
        break;
      case 'Day':
      default:
        formattedTimeFilter = DateFormat('yyyy-MM-dd').format(today);
        selectedDate = today;
        break;
    }
  }

  Future<void> _fetchChartData() async {
    await Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        timeSpent = [
          ChartData('Sun', 0),
          ChartData('Mon', 20),
          ChartData('Tue', 5),
          ChartData('Wed', 0),
          ChartData('Thu', 40),
          ChartData('Fri', 30),
          ChartData('Sat', 0),
        ];

        timeDistribution = [
          TaskData('Task 1', 40, Colors.blue),
          TaskData('Task 2', 25, Colors.red),
          TaskData('Task 3', 20, Colors.green),
          TaskData('Task 4', 10, Colors.orange),
          TaskData('Task 5', 5, Colors.purple),
        ];

        taskFinished = [
          FinishedTask('IT311', 4),
          FinishedTask('IT312', 2),
          FinishedTask('IT313', 4),
          FinishedTask('IT314', 1),
          FinishedTask('IT315', 6),
          FinishedTask('ES21a', 3),
        ];

        isLoading = false;
      });
    });
  }

  void _onTimeFilterSelected(String filter) {
    setState(() {
      selectedTimeFilter = filter;
      _updateFormattedTimeFilter();
      isLoading = true;
    });
    _fetchChartData();
  }

  // Function to show bottom sheet when the toggle is pressed
  void _showBottomSheet() {
    BottomSheetWidget.show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Reports'),
        leading: const BackButton(),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _showBottomSheet,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(40.0),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Tasks',
                          style: TextStyle(
                              fontSize: 16, color: Colors.grey.shade600)),
                      Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              ToggleButtonsDemo(
                labels: ['Day', 'Week', 'Month', 'Semester', 'Year'],
                onSelected: (filter) {
                  _onTimeFilterSelected(filter);
                  _showBottomSheet(); // Show the bottom sheet when toggle changes
                },
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  formattedTimeFilter.isNotEmpty
                      ? 'Selected Date/Range: $formattedTimeFilter'
                      : 'No date/range selected',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700),
                ),
              ),
              const SizedBox(height: 32),
              ChartContainer(
                title: 'Time Spent on Tasks',
                child: SfCartesianChart(
                  primaryXAxis: CategoryAxis(),
                  primaryYAxis: NumericAxis(
                      title: AxisTitle(text: 'Minutes'),
                      minimum: 0,
                      maximum: 50,
                      interval: 10),
                  series: <CartesianSeries>[
                    ColumnSeries<ChartData, String>(
                      dataSource: timeSpent,
                      xValueMapper: (ChartData data, _) => data.day,
                      yValueMapper: (ChartData data, _) => data.minutes,
                      color: Colors.blueGrey,
                    ),
                  ],
                ),
                isLoading: isLoading,
              ),
              const SizedBox(height: 16),
              ChartContainer(
                title: 'Task Time Distribution',
                child: SfCircularChart(
                  legend:
                      Legend(isVisible: true, position: LegendPosition.bottom),
                  series: <CircularSeries>[
                    DoughnutSeries<TaskData, String>(
                      dataSource: timeDistribution,
                      xValueMapper: (TaskData data, _) => data.task,
                      yValueMapper: (TaskData data, _) => data.hours,
                      pointColorMapper: (TaskData data, _) => data.color,
                    ),
                  ],
                ),
                isLoading: isLoading,
              ),
              const SizedBox(height: 16),
              ChartContainer(
                title: 'Tasks Finished',
                child: SfCartesianChart(
                  primaryXAxis: CategoryAxis(),
                  primaryYAxis: NumericAxis(title: AxisTitle(text: 'Tasks')),
                  series: <CartesianSeries>[
                    ColumnSeries<FinishedTask, String>(
                      dataSource: taskFinished,
                      xValueMapper: (FinishedTask data, _) => data.taskName,
                      yValueMapper: (FinishedTask data, _) => data.count,
                      color: Colors.blueGrey,
                    ),
                  ],
                ),
                isLoading: isLoading,
              ),
            ],
          ),
        ),
      ),
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
    Key? key,
  }) : super(key: key);

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

class ToggleButtonsDemo extends StatefulWidget {
  final List<String> labels;
  final ValueChanged<String> onSelected;

  const ToggleButtonsDemo({
    required this.labels,
    required this.onSelected,
    Key? key,
  }) : super(key: key);

  @override
  _ToggleButtonsDemoState createState() => _ToggleButtonsDemoState();
}

class _ToggleButtonsDemoState extends State<ToggleButtonsDemo> {
  late List<bool> _selections;

  @override
  void initState() {
    super.initState();
    _selections = List.generate(widget.labels.length, (index) => index == 0);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ToggleButtons(
          isSelected: _selections,
          onPressed: (int index) {
            setState(() {
              _selections =
                  List.generate(widget.labels.length, (i) => i == index);
            });
            widget.onSelected(widget.labels[index]);
          },
          children: widget.labels
              .map(
                (label) => SizedBox(
                  width: 90,
                  child: Center(
                      child: Text(label,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 14))),
                ),
              )
              .toList(),
          borderRadius: BorderRadius.circular(8),
          borderColor: const Color(0xFF173F70),
          selectedBorderColor: const Color(0xFF173F70),
          fillColor: const Color(0xFF173F70),
          selectedColor: Colors.white,
          color: Colors.black,
        ),
      ],
    );
  }
}

class ChartData {
  final String day;
  final double minutes;

  ChartData(this.day, this.minutes);
}

class TaskData {
  final String task;
  final double hours;
  final Color color;

  TaskData(this.task, this.hours, this.color);
}

class FinishedTask {
  final String taskName;
  final int count;

  FinishedTask(this.taskName, this.count);
}
