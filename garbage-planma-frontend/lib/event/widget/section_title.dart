import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: GoogleFonts.openSans(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF173F70), // Optional, customize color if needed
        ),
      ),
    );
  }
}
