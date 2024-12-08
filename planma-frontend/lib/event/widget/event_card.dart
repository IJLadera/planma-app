import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts
import 'package:intl/intl.dart';
import 'package:planma_app/event/view_event.dart';
import 'package:planma_app/models/events_model.dart';

class EventCard extends StatelessWidget {
  final Event event;

  const EventCard({
    super.key,
    required this.event,
  });

  String _formatTimeForDisplay(String time24) {
    final timeParts = time24.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    final timeOfDay = TimeOfDay(hour: hour, minute: minute);

    // Format to "H:mm a"
    final now = DateTime.now();
    final dateTime = DateTime(
      now.year,
      now.month,
      now.day,
      timeOfDay.hour,
      timeOfDay.minute,
    );
    return DateFormat.jm().format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final startTime = _formatTimeForDisplay(event.scheduledStartTime);
    final endTime = _formatTimeForDisplay(event.scheduledEndTime);


    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: () {
          // Navigate to the ViewEvent screen when tapped
          print("Navigating to EventDetailScreen with eventId: ${event.eventId}");
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventDetailScreen(event: event)
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Color(0xFFACEFDB),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.eventName,
                style: GoogleFonts.openSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF173F70),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$startTime - $endTime',
                style: GoogleFonts.openSans(
                  fontSize: 14,
                  color: Color(0xFF173F70),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
