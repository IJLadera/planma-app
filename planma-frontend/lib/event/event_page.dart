import 'package:flutter/material.dart';
import 'package:planma_app/event/create_event.dart';
import 'package:planma_app/event/widget/by_date_view.dart';
import 'package:planma_app/Providers/events_provider.dart';
import 'package:planma_app/event/widget/history_event.dart';
import 'package:planma_app/goals/widget/search_bar.dart';
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
          backgroundColor: Color(0xFFFFFFFF),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: IconButton(
                icon: Icon(Icons.history, color: Color(0xFF173F70), size: 28.0),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HistoryEventScreen()),
                  );
                },
              ),
            ),
          ],
        ),
        body: Column(children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(child: CustomSearchBar()),
                const SizedBox(width: 5),
                IconButton(
                  icon:
                      Icon(Icons.history, color: Color(0xFF173F70), size: 28.0),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HistoryEventScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: eventProvider.events.isEmpty
                ? Center(
                    child: Text(
                      'No events found',
                      style: GoogleFonts.openSans(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  )
                : ByDateView(
                    eventsView: eventProvider.events,
                  ),
          ),
        ]),
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
