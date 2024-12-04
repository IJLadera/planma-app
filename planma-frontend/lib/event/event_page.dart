import 'package:flutter/material.dart';
import 'package:planma_app/event/create_event.dart';
import 'package:planma_app/event/widget/event_card.dart';
import 'package:planma_app/event/widget/section_title.dart';
import 'package:planma_app/Providers/events_provider.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class EventsPage extends StatelessWidget {
  const EventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final eventsProvider = context.watch<EventsProvider>();
    final events = eventsProvider.events; // Assuming events is a List<Event>

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Events',
          style: GoogleFonts.openSans(
              fontWeight: FontWeight.bold, color: Color(0xFF173F70)),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Color(0xFFFFFFFF),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Search bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle:
                    GoogleFonts.openSans(), 
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // List of events
            Expanded(
              child: ListView(
                children: [
                  const SectionTitle(title: 'Today'),
                  ...events
                      .map((event) => EventCard(
                            eventName: event.eventName,
                            description: event.eventDesc,
                            location: event.location,
                            date: event.date,
                            timePeriod: event.time,
                            type: event.eventType,
                          ))
                      .toList(),
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
            MaterialPageRoute(builder: (context) => const AddEventScreen()),
          );
        },
        backgroundColor: const Color(0xFF173F70),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
