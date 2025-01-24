import 'package:flutter/material.dart';
import 'package:planma_app/core/dashboard.dart';
import 'package:planma_app/timetable/widget/button_sheet.dart';
import 'package:planma_app/timetable/widget/search.dart';
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 74.0),
                child: Text(
                  isCalendarActive ? 'Calendar View' : 'Time Blocking View',
                  style: GoogleFonts.openSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF173F70),
                  ),
                ),
              ),
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
                // child: Container(
                //   height: 50,
                //   padding: const EdgeInsets.symmetric(horizontal: 15),
                //   decoration: BoxDecoration(
                //     color: Colors.white,
                //     borderRadius: BorderRadius.circular(25),
                //     boxShadow: [
                //       BoxShadow(
                //         color: Colors.grey.withOpacity(0.3),
                //         blurRadius: 10,
                //         spreadRadius: 2,
                //         offset: const Offset(0, 3),
                //       ),
                //     ],
                //   ),
                //   child: Row(
                //     children: [
                //       const Icon(Icons.search, color: Colors.grey),
                //       const SizedBox(width: 10),
                //       const Text(
                //         'Search...',
                //         style: TextStyle(color: Colors.grey, fontSize: 16),
                //       ),
                //     ],
                //   ),
                // ),
                child: CustomSearchBar(),
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
                        color: Color(0xFF173F70),
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      selectedDecoration: BoxDecoration(
                        color: Color(0xFF173F70),
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: GoogleFonts.openSans(
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF173F70),
                        ),
                      ),
                      leftChevronIcon: const Icon(Icons.chevron_left,
                          color: Color(0xFF173F70)),
                      rightChevronIcon: const Icon(Icons.chevron_right,
                          color: Color(0xFF173F70)),
                    ),
                    daysOfWeekStyle: DaysOfWeekStyle(
                      weekdayStyle: GoogleFonts.openSans(
                        textStyle: const TextStyle(
                            color: Colors.grey, fontWeight: FontWeight.w600),
                      ),
                      weekendStyle: GoogleFonts.openSans(
                        textStyle: const TextStyle(
                            color: Colors.red, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  SizedBox(height: 20)
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
