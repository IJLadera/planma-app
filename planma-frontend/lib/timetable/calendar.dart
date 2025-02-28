import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:planma_app/Providers/schedule_entry_provider.dart';
import 'package:planma_app/core/dashboard.dart';
import 'package:planma_app/models/schedule_entry_model.dart';
import 'package:planma_app/timetable/widget/button_sheet.dart';
import 'package:planma_app/timetable/widget/search.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:planma_app/timetable/timetable.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomCalendar extends StatefulWidget {
  const CustomCalendar({super.key});

  @override
  _CalendarViewState createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CustomCalendar> {
  bool isCalendarActive = true; // Track which view is currently active
  DateTime focusedDay = DateTime.now(); // Tracks the currently displayed month
  DateTime selectedDay = DateTime.now(); // Tracks the selected day
  Map<DateTime, List<Map<String, String>>> events = {};

  @override
  void initState() {
    super.initState();
    _loadScheduleEntries();
  }

  DateTime normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  Future<void> _loadScheduleEntries() async {
    final provider = Provider.of<ScheduleEntryProvider>(context, listen: false);
    await provider.fetchScheduleEntries();

    Map<DateTime, List<Map<String, String>>> tempEvents = {};

    for (var entry in provider.scheduleEntries) {
      DateTime dateKey = normalizeDate(entry.scheduledDate);

      String name = "Unknown";

      if (entry.categoryType == "Event") {
        name = await provider.fetchEventName(entry.referenceId);
      } else if (entry.categoryType == "Task") {
        name = await provider.fetchTaskName(entry.referenceId);
      } else if (entry.categoryType == "Activity") {
        name = await provider.fetchActivityName(entry.referenceId);
      } else if (entry.categoryType == "Goal") {
        name = await provider.fetchGoalName(entry.referenceId);
      }

      Map<String, String> eventDetails = {
        "categoryType": entry.categoryType,
        "timeRange": "${entry.scheduledStartTime} - ${entry.scheduledEndTime}",
        "name": name,
      };

      if (tempEvents.containsKey(dateKey)) {
        tempEvents[dateKey]!.add(eventDetails);
      } else {
        tempEvents[dateKey] = [eventDetails];
      }
    }

    setState(() {
      events = tempEvents;
    });

    debugPrint("Loaded events: ${events.toString()}");
  }

  List<Map<String, String>> _getEventsForDay(DateTime day) {
    List<Map<String, String>> eventsForDay = events[normalizeDate(day)] ?? [];

    eventsForDay.sort((a, b) {
      // Parse times to compare them
      TimeOfDay startTimeA = _parseTime(a["timeRange"]!.split(" - ")[0]);
      TimeOfDay startTimeB = _parseTime(b["timeRange"]!.split(" - ")[0]);

      if (startTimeA.hour != startTimeB.hour) {
        return startTimeA.hour.compareTo(startTimeB.hour);
      }
      return startTimeA.minute.compareTo(startTimeB.minute);
    });

    return eventsForDay;
  }

  TimeOfDay _parseTime(String timeString) {
    List<String> parts = timeString.split(":");
    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);

    return TimeOfDay(hour: hour, minute: minute);
  }

  Color _getCategoryColor(String categoryType) {
    switch (categoryType) {
      case "Task":
        return Color(0xFFC0D7F3);
      case "Class":
        return Color(0xFFFFE1BF);
      case "Event":
        return Color(0xFFACEFDB);
      case "Activity":
        return Color(0xFFFBA2A2);
      case "Goal":
        return Color(0xFFD7C0F3);
      default:
        return Colors.grey;
    }
  }

  void switchView(bool isCalendar) {
    setState(() {
      isCalendarActive = isCalendar;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                color: Color(0xFF173F70),
                onPressed: () {
                  if (!isCalendarActive) {
                    switchView(true);
                  }
                },
              ),
              SizedBox(width: 16),
              ConstrainedBox(
                constraints: BoxConstraints(minWidth: 220),
                child: Center(
                  child: Text(
                    isCalendarActive ? 'Calendar' : 'Time Blocking',
                    style: GoogleFonts.openSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Color(0xFF173F70),
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                color: Color(0xFF173F70),
                onPressed: () {
                  if (isCalendarActive) {
                    switchView(false);
                  }
                },
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          if (isCalendarActive)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: () {
                  // Placeholder for search functionality
                },
                child: CustomSearchBar(),
              ),
            ),
          if (isCalendarActive)
            Expanded(
              child: Column(
                children: [
                  // Custom Calendar Header
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Left Chevron
                        IconButton(
                          icon: const Icon(Icons.chevron_left,
                              color: Color(0xFF173F70)),
                          onPressed: () {
                            setState(() {
                              focusedDay = DateTime(
                                  focusedDay.year, focusedDay.month - 1);
                            });
                          },
                        ),
                        // Spacer for Left Chevron
                        SizedBox(width: 16),
                        // Text for Month and Year with fixed width container
                        ConstrainedBox(
                          constraints: BoxConstraints(minWidth: 180),
                          child: Center(
                            child: Text(
                              DateFormat('MMMM yyyy').format(focusedDay),
                              style: GoogleFonts.openSans(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF173F70),
                              ),
                            ),
                          ),
                        ),
                        // Spacer for Right Chevron
                        SizedBox(width: 16),
                        // Right Chevron
                        IconButton(
                          icon: const Icon(Icons.chevron_right,
                              color: Color(0xFF173F70)),
                          onPressed: () {
                            setState(() {
                              focusedDay = DateTime(
                                  focusedDay.year, focusedDay.month + 1);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  // Calendar widget for the monthly view
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal:
                            16.0), // Space on sides of the TableCalendar
                    child: TableCalendar(
                      firstDay: DateTime(2000),
                      lastDay: DateTime(2100),
                      focusedDay: focusedDay,
                      selectedDayPredicate: (day) {
                        // Prevent selectedDecoration from overriding todayDecoration
                        if (isSameDay(day, DateTime.now())) {
                          return false;
                        }
                        return isSameDay(day, selectedDay);
                      },
                      onDaySelected: (selected, focused) {
                        setState(() {
                          selectedDay = selected;
                          focusedDay = focused;
                        });
                      },
                      eventLoader: (day) {
                        List<Map<String, String>> loadedEvents =
                            _getEventsForDay(day);
                        return loadedEvents;
                      },
                      onPageChanged: (focused) {
                        setState(() {
                          focusedDay = focused;
                        });
                      },
                      calendarStyle: CalendarStyle(
                        defaultTextStyle: GoogleFonts.openSans(
                          textStyle: const TextStyle(
                            color: Color(0xFF173F70),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        weekendTextStyle: GoogleFonts.openSans(
                          textStyle: const TextStyle(
                            color: Color(0xFF173F70),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        outsideTextStyle: GoogleFonts.openSans(
                          textStyle: const TextStyle(
                            color: Colors.grey,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        selectedTextStyle: GoogleFonts.openSans(
                          textStyle: const TextStyle(
                            color: Color(0xFF173F70),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        todayDecoration: BoxDecoration(
                          color: Color(0xFF173F70),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        selectedDecoration: BoxDecoration(
                          color: Color(0xFF173F70).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        defaultDecoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                        ),
                        weekendDecoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                        ),
                      ),
                      headerVisible: false,
                      daysOfWeekHeight: 60,
                      daysOfWeekStyle: DaysOfWeekStyle(
                        weekdayStyle: GoogleFonts.openSans(
                          textStyle: const TextStyle(
                              color: Color(0xFF8F9BB3),
                              fontWeight: FontWeight.w500,
                              fontSize: 12),
                        ),
                        weekendStyle: GoogleFonts.openSans(
                          textStyle: const TextStyle(
                              color: Color(0xFF8F9BB3),
                              fontWeight: FontWeight.w500,
                              fontSize: 12),
                        ),
                      ),
                      calendarBuilders: CalendarBuilders(
                        markerBuilder: (context, day, events) {
                          if (events.isEmpty) return SizedBox.shrink();
                          Set<String> uniqueCategories = {};
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: events
                                .map((event) {
                                  String categoryType =
                                      event is Map<String, String>
                                          ? event["categoryType"] ?? "Unknown"
                                          : "Unknown";

                                  // Limits marker number per categoryType
                                  if (uniqueCategories.contains(categoryType))
                                    return SizedBox.shrink();
                                  uniqueCategories.add(categoryType);

                                  Color markerColor =
                                      _getCategoryColor(categoryType);
                                  return Container(
                                    width: 5,
                                    height: 5,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 1),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: markerColor,
                                    ),
                                  );
                                })
                                .toList()
                                .where((widget) => widget is! SizedBox)
                                .toList(),
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: ListView(
                      children: _getEventsForDay(selectedDay).map((event) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 10.0),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                            color: _getCategoryColor(event["categoryType"]!),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    event["name"]!,
                                    style: GoogleFonts.openSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF173F70),
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    event[
                                        "timeRange"]!, // Replace with actual details if available
                                    style: GoogleFonts.openSans(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          if (!isCalendarActive)
            const Expanded(
                child: Timetable()), // Show Timetable if in Time Blocking View
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: Container(
          height: 10.0,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30.0),
              topRight: Radius.circular(30.0),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.home, size: 40),
                  color: Color(0xFF173F70),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Dashboard()),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_month, size: 40),
                  color: Color(0xFF173F70),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CustomCalendar()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          BottomSheetWidget.show(context);
        },
        backgroundColor: Color(0xFF173F70),
        shape: const CircleBorder(),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
