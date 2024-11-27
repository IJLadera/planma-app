import 'package:flutter/material.dart';
import 'package:planma_app/event/create_event.dart';
import 'package:planma_app/event/widget/event_card.dart';
import 'package:planma_app/event/widget/section_title.dart';
import 'package:planma_app/Providers/events_provider.dart';
import 'package:provider/provider.dart';

class EventsPage extends StatelessWidget {
  const EventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    String? eventName = context.watch<EventsProvider>().eventName;
    String? eventDesc = context.watch<EventsProvider>().eventDesc;
    String? location = context.watch<EventsProvider>().location;
    String? date = context.watch<EventsProvider>().date;
    String? time = context.watch<EventsProvider>().time;
    String? eventType = context.watch<EventsProvider>().eventType;

    return Scaffold(
      appBar: AppBar(
        title: Text('Events'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  SectionTitle(title: 'Today'),
                  EventCard(
                    eventName: '$eventName',
                    description: '$eventDesc',
                    location: '$location',
                    date: '$date',
                    timePeriod: '$time',
                    type: '$eventType',
                  ),
                  EventCard(
                    eventName: 'Date with GF',
                    description: 'Monthsary Date',
                    location: 'SM Downtown',
                    date: '11 January 2024',
                    timePeriod: '11:00 AM - 12:30 PM',
                    type: 'Academic',
                  ),
                  SectionTitle(title: 'December 18'),
                  EventCard(
                    eventName: 'Date with GF',
                    description: 'Monthsary Date',
                    location: 'SM Downtown',
                    date: '11 January 2024',
                    timePeriod: '11:00 AM - 12:30 PM',
                    type: 'Academic',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddEventState()),
          );
        },
        backgroundColor: Color(0xFF173F70),
        child: Icon(Icons.add),
      ),
    );
  }
}
