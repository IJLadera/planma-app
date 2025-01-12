import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:planma_app/Providers/events_provider.dart';
import 'package:planma_app/event/view_event.dart';
import 'package:provider/provider.dart';

class HistoryEventScreen extends StatefulWidget {
  const HistoryEventScreen({super.key});

  @override
  State<HistoryEventScreen> createState() => _HistoryEventScreenState();
}

class _HistoryEventScreenState extends State<HistoryEventScreen> {
  @override
  void initState() {
    super.initState();
    final eventProvider = Provider.of<EventsProvider>(context, listen: false);
    // Automatically fetch events when screen loads
    eventProvider.fetchPastEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EventsProvider>(
      builder: (context, eventProvider, child) {
        final events = eventProvider.pastEvents;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'History',
              style: GoogleFonts.openSans(
                fontWeight: FontWeight.bold,
                color: Color(0xFF173F70),
              ),
            ),
            backgroundColor: Colors.white,
            iconTheme: IconThemeData(color: Color(0xFF173F70)),
          ),
          body: events.isEmpty
              ? Center(
                  child: Text(
                    'No past events available.',
                    style: GoogleFonts.openSans(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    final formattedDate = DateFormat('dd MMMM yyyy')
                        .format(event.scheduledDate)
                        .toString();
                    return Card(
                      margin: const EdgeInsets.all(10),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.blueAccent,
                          child: Icon(
                            Icons.event,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          event.eventName, // Use event's title
                          style: GoogleFonts.openSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          'Event Date: $formattedDate', // Use event's scheduled date
                          style: GoogleFonts.openSans(color: Colors.grey),
                        ),
                        trailing: Icon(Icons.chevron_right, color: Colors.grey),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EventDetailScreen(event: event),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
