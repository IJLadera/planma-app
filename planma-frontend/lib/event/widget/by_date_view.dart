
import 'package:flutter/material.dart';
import 'package:planma_app/event/widget/event_card.dart';
import 'package:planma_app/models/events_model.dart';

class ByDateView extends StatelessWidget {
  final List<Event> eventsView;
  const ByDateView({super.key, required this.eventsView});

  @override
  Widget build(BuildContext context) {
    final List<int?> eventId = eventsView
        .map((e) => e.eventId) 
        .toList();
    print ("eventId: $eventId");
    return ListView.builder(
        itemCount: eventsView.length,
        itemBuilder: (context, index) {
          final event = eventsView[index];
          return SizedBox(
            child: EventCard(event: event),
          );
        });
  }
}
