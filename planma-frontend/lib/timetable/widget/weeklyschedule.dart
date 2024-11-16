import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class WeeklySchedule extends StatelessWidget {
  const WeeklySchedule({super.key});

  @override
  Widget build(BuildContext context) {
    // Getting the weekly classes
    List<Appointment> weeklyClasses = getWeeklyClasses();

    // Grouping the appointments by days (Monday, Tuesday, etc.)
    Map<String, List<Appointment>> groupedClasses = _groupClassesByDay(weeklyClasses);

    return ListView.builder(
      itemCount: groupedClasses.keys.length,
      itemBuilder: (context, index) {
        String day = groupedClasses.keys.elementAt(index);
        List<Appointment> appointments = groupedClasses[day]!;

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                day,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Column(
                children: appointments.map((appointment) {
                  return ListTile(
                    title: Text(appointment.subject),
                    subtitle: Text(
                        '${appointment.startTime.toString().substring(11, 16)} - ${appointment.endTime.toString().substring(11, 16)}'),
                    tileColor: appointment.color.withOpacity(0.1),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  // Function to group classes by the day of the week
  Map<String, List<Appointment>> _groupClassesByDay(List<Appointment> weeklyClasses) {
    // List of days in the week
    const List<String> weekDays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];

    Map<String, List<Appointment>> groupedClasses = {};
    
    // Initialize the map with empty lists for each day
    for (String day in weekDays) {
      groupedClasses[day] = [];
    }

    // Group the classes by their weekday
    for (var appointment in weeklyClasses) {
      String dayName = weekDays[appointment.startTime.weekday - 1]; // Get the day name
      groupedClasses[dayName]?.add(appointment); // Add the appointment to the respective day
    }

    return groupedClasses;
  }

  // Function to get a list of weekly classes as appointments
  List<Appointment> getWeeklyClasses() {
    final List<Appointment> classes = <Appointment>[];
    final DateTime today = DateTime.now();

    // Example Classes (same as in Timetable)
    classes.add(Appointment(
      startTime: getNextWeekday(today, DateTime.monday, 9),
      endTime: getNextWeekday(today, DateTime.monday, 11),
      subject: 'Mathematics',
      color: Colors.blueAccent,
    ));
    classes.add(Appointment(
      startTime: getNextWeekday(today, DateTime.monday, 14),
      endTime: getNextWeekday(today, DateTime.monday, 16),
      subject: 'History',
      color: Colors.purple,
    ));

    classes.add(Appointment(
      startTime: getNextWeekday(today, DateTime.tuesday, 10),
      endTime: getNextWeekday(today, DateTime.tuesday, 12),
      subject: 'Biology',
      color: Colors.green,
    ));
    classes.add(Appointment(
      startTime: getNextWeekday(today, DateTime.tuesday, 15),
      endTime: getNextWeekday(today, DateTime.tuesday, 17),
      subject: 'Literature',
      color: Colors.orange,
    ));

    classes.add(Appointment(
      startTime: getNextWeekday(today, DateTime.wednesday, 11),
      endTime: getNextWeekday(today, DateTime.wednesday, 13),
      subject: 'Physics',
      color: Colors.orange,
    ));
    classes.add(Appointment(
      startTime: getNextWeekday(today, DateTime.wednesday, 15),
      endTime: getNextWeekday(today, DateTime.wednesday, 17),
      subject: 'Computer Science',
      color: Colors.blue,
    ));

    classes.add(Appointment(
      startTime: getNextWeekday(today, DateTime.friday, 9),
      endTime: getNextWeekday(today, DateTime.friday, 11),
      subject: 'Chemistry',
      color: Colors.red,
    ));
    classes.add(Appointment(
      startTime: getNextWeekday(today, DateTime.friday, 14),
      endTime: getNextWeekday(today, DateTime.friday, 16),
      subject: 'Economics',
      color: Colors.yellow,
    ));

    return classes;
  }

  // Function to get the next weekday for scheduling
  DateTime getNextWeekday(DateTime startDate, int weekday, int hour) {
    final int daysToAdd = (weekday - startDate.weekday + 7) % 7;
    final DateTime nextDate = startDate.add(Duration(days: daysToAdd));
    return DateTime(nextDate.year, nextDate.month, nextDate.day, hour);
  }
}
