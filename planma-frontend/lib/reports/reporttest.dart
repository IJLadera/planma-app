import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:planma_app/Providers/user_provider.dart';
import 'package:planma_app/reports/reportservice.dart';
import 'package:provider/provider.dart';
import 'package:jwt_decode/jwt_decode.dart';

class Report extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  Report({super.key});

  @override
  _ReportState createState() => _ReportState();
}

class _ReportState extends State<Report> {
  List<_ChartData> data = []; // Initialize as an empty list
  late TooltipBehavior _tooltip;
  bool _isLoading = true; // Add a loading indicator flag

  @override
  void initState() {
    super.initState();
    _tooltip = TooltipBehavior(enable: true);
    _initializeData();
  }

  void _initializeData() async {
    try {
      final carreon =
          Jwt.parseJwt(context.read<UserProvider>().accessToken!)['user_id'];
          await context.read<ReportAct>().fetchActivities(carreon);
          final activityName = context.read<ReportAct>().activName ?? 'Unknown Activity';
      setState(() {
        data = [
          _ChartData('CN', 12),
          _ChartData(activityName, 12),
        ];
        _isLoading = false; // Data is loaded
      });
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        _isLoading = false; // Stop loading even if an error occurs
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Syncfusion Flutter Chart'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(), // Show loader while data is loading
            )
          : SfCartesianChart(
              primaryXAxis: CategoryAxis(),
              primaryYAxis: NumericAxis(minimum: 0, maximum: 40, interval: 10),
              tooltipBehavior: _tooltip,
              series: <CartesianSeries<_ChartData, String>>[
                ColumnSeries<_ChartData, String>(
                  dataSource: data,
                  xValueMapper: (_ChartData data, _) => data.x,
                  yValueMapper: (_ChartData data, _) => data.y,
                  name: 'Gold',
                  color: const Color.fromRGBO(8, 142, 255, 1),
                ),
              ],
            ),
    );
  }
}

class _ChartData {
  _ChartData(this.x, this.y);

  final String x;
  final double y;
}
