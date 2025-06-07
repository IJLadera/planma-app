import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:planma_app/Providers/schedule_entry_provider.dart';
import 'package:planma_app/models/schedule_entry_model.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:google_fonts/google_fonts.dart';

class Timetable extends StatefulWidget {
  const Timetable({super.key});

  @override
  State<Timetable> createState() => _TimetableState();
}

class _TimetableState extends State<Timetable> {
  late CalendarController _calendarController;
  String _headerText = '';
  int _daysInView = 7;
  List<Appointment> _appointments = [];
  late _AppointmentDataSource _dataSource;

  @override
  void initState() {
    super.initState();
    _calendarController = CalendarController();
    _updateHeaderText(DateTime.now());
    _loadScheduleEntries();
    _dataSource = _AppointmentDataSource([]);
  }

  void _updateHeaderText(DateTime date) {
    if (mounted) {
      setState(() {
        _headerText = DateFormat('MMMM yyyy').format(date);
      });
    }
  }

  void _changeCalendarView(CalendarView view, int days) {
    setState(() {
      _calendarController.view = view;
      _daysInView = days;
    });
  }

  Future<void> _loadScheduleEntries() async {
    final provider = Provider.of<ScheduleEntryProvider>(context, listen: false);
    await provider.fetchScheduleEntries();

    List<Appointment> tempAppointments = [];

    for (var entry in provider.scheduleEntries) {
      String name = "Unknown";
      String status = "Pending";

      if (entry.categoryType == "Event") {
        name = await provider.fetchEventName(entry.referenceId);
      } else if (entry.categoryType == "Task") {
        Map<String, dynamic> taskDetails =
            await provider.fetchTaskDetails(entry.referenceId);
        name = taskDetails["task_name"] ?? "Unknown";
        status = taskDetails["status"] ?? "Pending";
      } else if (entry.categoryType == "Activity") {
        Map<String, dynamic> activityDetails =
            await provider.fetchActivityDetails(entry.referenceId);
        name = activityDetails["activity_name"] ?? "Unknown";
        status = activityDetails["status"] ?? "Pending";
      } else if (entry.categoryType == "Goal") {
        Map<String, dynamic> goalDetails =
            await provider.fetchGoalDetails(entry.referenceId);
        name = goalDetails["goal_name"] ?? "Unknown";
        status = goalDetails["status"] ?? "Pending";
      } else if (entry.categoryType == "Class") {
        name = await provider.fetchClassDetails(entry.referenceId);
      }

      Color appointmentColor = _getCategoryColor(entry.categoryType);
      if (status == "Completed") {
        appointmentColor = appointmentColor.withOpacity(0.4);
      }

      tempAppointments.add(Appointment(
        startTime: DateTime.parse(
            '${entry.scheduledDate.toIso8601String().split('T')[0]}T${entry.scheduledStartTime}'),
        endTime: DateTime.parse(
            '${entry.scheduledDate.toIso8601String().split('T')[0]}T${entry.scheduledEndTime}'),
        subject: name,
        color: appointmentColor,
        notes: status,
      ));
    }

    setState(() {
      _appointments = tempAppointments;
      _dataSource = _AppointmentDataSource(_appointments);
    });
  }

  List<Appointment> getAppointmentsFromScheduleEntries(
      List<ScheduleEntry> entries) {
    return entries.map((entry) {
      DateTime startDateTime = DateTime.parse(
          '${entry.scheduledDate.toIso8601String().split('T')[0]}T${entry.scheduledStartTime}');
      DateTime endDateTime = DateTime.parse(
          '${entry.scheduledDate.toIso8601String().split('T')[0]}T${entry.scheduledEndTime}');

      return Appointment(
        startTime: startDateTime,
        endTime: endDateTime,
        subject: entry.categoryType, // You can customize this
        color: _getCategoryColor(entry.categoryType),
        notes: entry.entryId, // Store the entry ID for reference
      );
    }).toList();
  }

  Color _getCategoryColor(String categoryType) {
    switch (categoryType) {
      case "Task":
        return Color(0xFF0095FF);
      case "Class":
        return Color(0xFFFFBB70);
      case "Event":
        return Color(0xFF30BB90);
      case "Activity":
        return Color(0xFFFF5656);
      case "Goal":
        return Color(0xFFB480F3);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        // Custom Header with centered text and left kebab menu
        Container(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          color: Colors.white,
          child: Row(
            children: [
              // Kebab Menu
              PopupMenuButton<int>(
                icon: const Icon(Icons.more_vert, color: Color(0xFF173F70)),
                onSelected: (int value) {
                  if (value == 1) {
                    _changeCalendarView(CalendarView.day, 1);
                  } else if (value == 2) {
                    _changeCalendarView(CalendarView.week, 3);
                  } else if (value == 3) {
                    _changeCalendarView(CalendarView.week, 7);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 1, child: Text("Day View")),
                  const PopupMenuItem(value: 2, child: Text("3-Day View")),
                  const PopupMenuItem(value: 3, child: Text("Week View")),
                ],
              ),
              // Centered Header Title
              Expanded(
                child: Text(
                  _headerText,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.openSans(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF173F70),
                      backgroundColor: Colors.white),
                ),
              ),
              // Invisible Placeholder to balance the Row layout
              const SizedBox(width: 40),
            ],
          ),
        ),
        // Timetable
        Expanded(
          child: SfCalendar(
            backgroundColor: Colors.white,
            controller: _calendarController,
            view: CalendarView.week,
            dataSource: _appointments.isNotEmpty
                ? _dataSource
                : _AppointmentDataSource([]),
            appointmentBuilder: (context, calendarAppointmentDetails) {
              if (_appointments.isEmpty) {
                return Container();
              }
              return _dataSource.buildAppointmentWidget(
                  context, calendarAppointmentDetails);
            },
            timeSlotViewSettings: TimeSlotViewSettings(
              startHour: 0,
              endHour: 24,
              timeTextStyle: const TextStyle(
                fontSize: 13,
                color: Color(0xFF8F9BB3),
                fontWeight: FontWeight.w500,
              ),
              timeIntervalHeight: 60,
              timeRulerSize: 80,
              numberOfDaysInView: _daysInView,
              dayFormat: 'EEE',
            ),
            cellBorderColor: Color(0xFF8F9BB3),
            headerHeight: 0,
            viewHeaderHeight: 75,
            viewHeaderStyle: ViewHeaderStyle(
              // backgroundColor: Colors.white,
              dateTextStyle: GoogleFonts.openSans(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Color(0xFF173F70),
              ),
              dayTextStyle: GoogleFonts.openSans(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF8F9BB3),
              ),
            ),
            todayHighlightColor: Color(0xFF1D4E89),
            onViewChanged: (ViewChangedDetails details) {
              if (details.visibleDates.isNotEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _updateHeaderText(
                      details.visibleDates[details.visibleDates.length ~/ 2]);
                });
              }
            },
            onTap: (CalendarTapDetails details) {
              if (details.appointments != null &&
                  details.appointments!.isNotEmpty) {
                final Appointment appointment = details.appointments![0];
                _showClassDetails(context, appointment);
              }
            },
          ),
        ),
      ],
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
                'Details',
                style: GoogleFonts.openSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF173F70)),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.book, color: Colors.blueAccent),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      appointment.subject,
                      style: GoogleFonts.openSans(
                          fontSize: 18, color: Color(0xFF173F70)),
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
                      style: GoogleFonts.openSans(
                          fontSize: 18, color: Color(0xFF173F70)),
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
                      style: GoogleFonts.openSans(
                          fontSize: 18, color: Color(0xFF173F70)),
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

// List<Appointment> getWeeklyClasses() {
//   final List<Appointment> classes = <Appointment>[];
//   final DateTime today = DateTime.now();

//   classes.addAll(_createRecurringClass(
//     subject: 'Subject 1',
//     startTime: getNextWeekday(today, DateTime.monday, 9),
//     endTime: getNextWeekday(today, DateTime.monday, 11),
//     weeks: 4,
//     color: Colors.blueAccent,
//   ));

//   classes.addAll(_createRecurringClass(
//     subject: 'Subject 2',
//     startTime: getNextWeekday(today, DateTime.monday, 14),
//     endTime: getNextWeekday(today, DateTime.monday, 16),
//     weeks: 4,
//     color: Colors.purple,
//   ));

//   classes.addAll(_createRecurringClass(
//     subject: 'Subject 3',
//     startTime: getNextWeekday(today, DateTime.tuesday, 10),
//     endTime: getNextWeekday(today, DateTime.tuesday, 12),
//     weeks: 4,
//     color: Colors.green,
//   ));

//   return classes;
// }

// List<Appointment> _createRecurringClass({
//   required String subject,
//   required DateTime startTime,
//   required DateTime endTime,
//   required int weeks,
//   required Color color,
// }) {
//   List<Appointment> recurringClasses = [];
//   for (int i = 0; i < weeks; i++) {
//     DateTime start =
//         startTime.add(Duration(days: i * 7)); // Add 7 days for each week
//     DateTime end = endTime.add(Duration(days: i * 7));

//     recurringClasses.add(Appointment(
//       startTime: start,
//       endTime: end,
//       subject: subject,
//       color: color,
//     ));
//   }
//   return recurringClasses;
// }

DateTime getNextWeekday(DateTime startDate, int weekday, int hour) {
  final int daysToAdd = (weekday - startDate.weekday + 7) % 7;
  final DateTime nextDate = startDate.add(Duration(days: daysToAdd));
  return DateTime(nextDate.year, nextDate.month, nextDate.day, hour);
}

class _AppointmentDataSource extends CalendarDataSource {
  _AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }

  @override
  Widget buildAppointmentWidget(
      BuildContext context, CalendarAppointmentDetails details) {
    final Appointment appointment = details.appointments.first;

    // Check if task is completed
    bool isCompleted = appointment.notes == "Completed";

    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: appointment.color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        appointment.subject, // Keep raw name, apply styling below
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          decoration: isCompleted
              ? TextDecoration.lineThrough
              : TextDecoration.none, // ✅ Strikethrough for completed tasks
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
