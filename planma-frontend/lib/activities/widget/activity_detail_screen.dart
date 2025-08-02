import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts

class ActivityDetailsScreen extends StatelessWidget {
  final String title;
  final String? detail;
  final TextStyle? textStyle;

  const ActivityDetailsScreen({
    super.key,
    required this.title,
    this.detail,
    this.textStyle,
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
                color: Color(0xFF173F70),
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              (detail == null || detail!.trim().isEmpty) ? 'No description' : detail!,
              style: GoogleFonts.openSans(
                color: Color(0xFF173F70),
                fontWeight: (detail == null || detail!.trim().isEmpty) ? FontWeight.w500 : FontWeight.bold,
                fontSize: 14,
                fontStyle: (detail == null || detail!.trim().isEmpty) ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
