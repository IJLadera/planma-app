import 'package:flutter/material.dart';
import 'package:planma_app/event/widget/event_card.dart';
import 'package:planma_app/models/events_model.dart';
import 'package:google_fonts/google_fonts.dart';

class ByDateView extends StatelessWidget {
  final List<Event> eventsView;
  const ByDateView({super.key, required this.eventsView});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Categorize events
    final Map<String, List<Event>> groupedevents = {
      "Past": eventsView
          .where((event) => event.scheduledDate.isBefore(today))
          .toList(),
      "Today": eventsView
          .where((event) => event.scheduledDate.isAtSameMomentAs(today))
          .toList(),
      "Tomorrow": eventsView
          .where((event) => event.scheduledDate
              .isAtSameMomentAs(today.add(const Duration(days: 1))))
          .toList(),
      "This Week": eventsView.where((event) {
        final weekEnd = today.add(Duration(days: 7 - today.weekday));
        return event.scheduledDate.isAfter(today) &&
            event.scheduledDate.isBefore(weekEnd) &&
            !event.scheduledDate
                .isAtSameMomentAs(today.add(const Duration(days: 1)));
      }).toList(),
      "Future": eventsView.where((event) {
        final weekEnd = today.add(Duration(days: 7 - today.weekday));
        return event.scheduledDate.isAfter(weekEnd) &&
            !event.scheduledDate
                .isAtSameMomentAs(today.add(const Duration(days: 1)));
      }).toList(),
    };

    return ListView(
      children: groupedevents.entries.map((entry) {
        final category = entry.key;
        final events = entry.value;

        return events.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 16.0, right: 16.0, bottom: 8.0),
                      child: Text(
                        category,
                        style: GoogleFonts.openSans(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF173F70)),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: events.length,
                      itemBuilder: (context, idx) {
                        final event = events[idx];
                        return SizedBox(
                          // height: 120,
                          child: EventCard(isByDate: true, event: event),
                        );
                      },
                    ),
                  ],
                ),
              )
            : Container();
      }).toList(),
    );
  }
}
