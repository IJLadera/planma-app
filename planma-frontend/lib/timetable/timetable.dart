import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:planma_app/timetable/widget/weeklyschedule.dart'; // wala pa ni na gamit for now

class Timetable extends StatelessWidget {
  const Timetable({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Timetable'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: SfCalendar(
              view: CalendarView.week,
              dataSource: ClassScheduleDataSource(getWeeklyClasses()),
              timeSlotViewSettings: const TimeSlotViewSettings(
                startHour: 6,
                endHour: 22,
              ),
              onTap: (CalendarTapDetails details) {
                if (details.appointments != null &&
                    details.appointments!.isNotEmpty) {
                  final Appointment appointment =
                      details.appointments![0];
                  _showClassDetails(
                      context, appointment);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showClassDetails(BuildContext context, Appointment appointment) {
    const List<String> weekDays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];

    // Get the weekday name using the weekday number
    String dayName =
        weekDays[appointment.startTime.weekday - 1];

    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Class Details',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 16),
                  Text('Subject: ${appointment.subject}'),
                  Text(
                      'Time: ${appointment.startTime.toString().substring(11, 16)} - ${appointment.endTime.toString().substring(11, 16)}'),
                  Text('Day: $dayName'), // Display the actual day
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// Function to get a list of weekly classes as appointments
List<Appointment> getWeeklyClasses() {
  final List<Appointment> classes = <Appointment>[];
  final DateTime today = DateTime.now();

  // Example Classes
  classes.addAll(_createRecurringClass(
    subject: 'Subject 1',
    startTime: getNextWeekday(today, DateTime.monday, 9),
    endTime: getNextWeekday(today, DateTime.monday, 11),
    weeks: 4, // Number of weeks the class will recur
    color: Colors.blueAccent,
  ));
  
  classes.addAll(_createRecurringClass(
    subject: 'Subject 2',
    startTime: getNextWeekday(today, DateTime.monday, 14),
    endTime: getNextWeekday(today, DateTime.monday, 16),
    weeks: 4,
    color: Colors.purple,
  ));

  classes.addAll(_createRecurringClass(
    subject: 'Subject 3',
    startTime: getNextWeekday(today, DateTime.tuesday, 10),
    endTime: getNextWeekday(today, DateTime.tuesday, 12),
    weeks: 4,
    color: Colors.green,
  ));

  // Continue adding classes as needed...

  return classes;
}

List<Appointment> _createRecurringClass({
  required String subject,
  required DateTime startTime,
  required DateTime endTime,
  required int weeks,
  required Color color,
}) {
  List<Appointment> recurringClasses = [];
  for (int i = 0; i < weeks; i++) {
    DateTime start = startTime.add(Duration(days: i * 7)); // Add 7 days for each week
    DateTime end = endTime.add(Duration(days: i * 7));
    
    recurringClasses.add(Appointment(
      startTime: start,
      endTime: end,
      subject: subject,
      color: color,
    ));
  }
  return recurringClasses;
}

DateTime getNextWeekday(DateTime startDate, int weekday, int hour) {
  final int daysToAdd = (weekday - startDate.weekday + 7) % 7;
  final DateTime nextDate = startDate.add(Duration(days: daysToAdd));
  return DateTime(nextDate.year, nextDate.month, nextDate.day, hour);
}

// Custom DataSource class to provide data to the calendar
class ClassScheduleDataSource extends CalendarDataSource {
  ClassScheduleDataSource(List<Appointment> source) {
    appointments = source;
  }
}
