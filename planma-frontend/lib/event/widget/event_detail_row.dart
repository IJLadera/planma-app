import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts

class EventDetailRow extends StatelessWidget {
  final String title;
  final String value;

  const EventDetailRow({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              title,
              style: GoogleFonts.openSans(
                fontWeight: FontWeight.bold,
                color: Color(0xFF173F70),
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              style: GoogleFonts.openSans(
                color: Color(0xFF173F70),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
