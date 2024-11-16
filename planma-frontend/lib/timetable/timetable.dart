import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class Timetable extends StatelessWidget {
  const Timetable({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SfCalendar(
        view: CalendarView.week,
        dataSource: ClassScheduleDataSource(getWeeklyClasses()),
        timeSlotViewSettings: const TimeSlotViewSettings(
          startHour: 6,
          endHour: 22,
        ),
        onTap: (CalendarTapDetails details) {
          if (details.appointments != null &&
              details.appointments!.isNotEmpty) {
            final Appointment appointment = details.appointments![0];
            _showClassDetails(context, appointment);
          }
        },
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

    String dayName = weekDays[appointment.startTime.weekday - 1];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.4, // 40% height
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  height: 5,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Class Details',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.book, color: Colors.blueAccent),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      appointment.subject,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.access_time, color: Colors.green),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${appointment.startTime.toString().substring(11, 16)} - ${appointment.endTime.toString().substring(11, 16)}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.calendar_today, color: Colors.orange),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      dayName,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

List<Appointment> getWeeklyClasses() {
  final List<Appointment> classes = <Appointment>[];
  final DateTime today = DateTime.now();

  classes.addAll(_createRecurringClass(
    subject: 'Subject 1',
    startTime: getNextWeekday(today, DateTime.monday, 9),
    endTime: getNextWeekday(today, DateTime.monday, 11),
    weeks: 4,
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
    DateTime start =
        startTime.add(Duration(days: i * 7)); // Add 7 days for each week
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

class ClassScheduleDataSource extends CalendarDataSource {
  ClassScheduleDataSource(List<Appointment> source) {
    appointments = source;
  }
}
