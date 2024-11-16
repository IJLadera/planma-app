import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart'; 
import 'package:planma_app/timetable/timetable.dart';

class CustomCalendar extends StatefulWidget {
  const CustomCalendar({super.key});

  @override
  _CalendarViewState createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CustomCalendar> {
  bool isCalendarActive = true; // Track which view is currently active
  DateTime focusedDay = DateTime.now(); // Tracks the currently displayed month
  DateTime selectedDay = DateTime.now(); // Tracks the selected day

  void switchView(bool isCalendar) {
    setState(() {
      isCalendarActive = isCalendar;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_left),
              onPressed: () {
                if (!isCalendarActive) {
                  switchView(true);
                }
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                isCalendarActive ? 'Calendar View' : 'Time Blocking View',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_right),
              onPressed: () {
                if (isCalendarActive) {
                  switchView(false);
                }
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          if (isCalendarActive)
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: GestureDetector(
                onTap: () {
                  // Placeholder for search functionality
                },
                child: Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.grey),
                      const SizedBox(width: 10),
                      const Text(
                        'Search...',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (isCalendarActive)
            Expanded(
              child: Column(
                children: [
                  // Calendar widget for the monthly view
                  TableCalendar(
                    firstDay: DateTime(2000), // Customize as needed
                    lastDay: DateTime(2100),
                    focusedDay: focusedDay,
                    selectedDayPredicate: (day) {
                      return isSameDay(selectedDay, day);
                    },
                    onDaySelected: (selected, focused) {
                      setState(() {
                        selectedDay = selected;
                        focusedDay = focused;
                      });
                    },
                    onPageChanged: (focused) {
                      setState(() {
                        focusedDay = focused;
                      });
                    },
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: Colors.blueAccent,
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      leftChevronIcon: const Icon(Icons.chevron_left),
                      rightChevronIcon: const Icon(Icons.chevron_right),
                    ),
                  ),
                ],
              ),
            ),
          if (!isCalendarActive) const Expanded(child: Timetable()), // Show Timetable if in Time Blocking View
        ],
      ),
    );
  }
}
