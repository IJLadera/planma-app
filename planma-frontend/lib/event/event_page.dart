import 'package:flutter/material.dart';
import 'package:planma_app/event/create_event.dart';
import 'package:planma_app/event/widget/by_date_view.dart';
import 'package:planma_app/event/widget/event_card.dart';
import 'package:planma_app/Providers/events_provider.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  @override
  void initState() {
    super.initState();
    final eventProvider = Provider.of<EventsProvider>(context, listen: false);
    // Automatically fetch tasks when screen loads
    eventProvider.fetchEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EventsProvider>(builder: (context, eventProvider, child) {
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
                  hintStyle: GoogleFonts.openSans(),
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // List of events
              Expanded(
                child: eventProvider.events.isEmpty
                    ? Center(
                        child: Text(
                          'No events found',
                          style: GoogleFonts.openSans(
                              fontSize: 16, color: Colors.black),
                        ),
                      )
                    : ByDateView(
                        eventsView: eventProvider.events,
                      ),
              )
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
    });
  }
}
