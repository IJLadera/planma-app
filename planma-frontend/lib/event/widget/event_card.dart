import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts
import 'package:planma_app/event/view_event.dart';

class EventCard extends StatelessWidget {
  final String eventName;
  final String timePeriod;
  final String description;
  final String location;
  final String date;
  final String type;

  const EventCard({
    super.key,
    required this.eventName,
    required this.timePeriod,
    required this.description,
    required this.location,
    required this.date,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: () {
          // Navigate to the ViewEvent screen when tapped
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ViewEvent(
                eventName: eventName,
                description: description,
                location: location,
                date: date,
                timePeriod: timePeriod,
                type: type,
              ),
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
                eventName,
                style: GoogleFonts.openSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF173F70),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                timePeriod,
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
