import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:planma_app/reports/widget/bottom_sheet.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
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
        formattedTimeFilter = DateFormat('MMMM').format(today);
        selectedDate = today;
        break;
      case 'Year':
        formattedTimeFilter = DateFormat('yyyy').format(today);
        selectedDate = today;
        break;
      case 'Semester':
        if (today.month >= 8 && today.month <= 12) {
          formattedTimeFilter =
              '1st Semester ${DateFormat('yyyy').format(today)}';
        } else {
          formattedTimeFilter =
              '2nd Semester ${DateFormat('yyyy').format(today)}';
        }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
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
                onTap: () {
                  //BottomSheetWidget.show(context);
                },
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
                      Text(
                        'Tasks',
                        style: TextStyle(
                            fontSize: 16, color: Colors.grey.shade600),
                      ),
                      Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              ToggleButtonsDemo(
                labels: ['Day', 'Week', 'Month', 'Semester', 'Year'],
                onSelected: _onTimeFilterSelected,
              ),
              const SizedBox(height: 16),

              // Display selected time filter
              Center(
                child: Text(
                  formattedTimeFilter.isNotEmpty
                      ? 'Selected Date/Range: $formattedTimeFilter'
                      : 'No date/range selected',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Bar chart: Time spent
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
                    ColumnSeries<ChartData, String>(
                      dataSource: timeSpent,
                      xValueMapper: (ChartData data, _) => data.day,
                      yValueMapper: (ChartData data, _) => data.minutes,
                      color: Colors.blueGrey,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Doughnut chart: Task distribution
              ChartContainer(
                title: 'Task Time Distribution',
                isLoading: isLoading,
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
              ),

              const SizedBox(height: 16),

              // Bar chart: Tasks finished
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
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Chart container widget for consistency
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

// Chart Data classes
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
