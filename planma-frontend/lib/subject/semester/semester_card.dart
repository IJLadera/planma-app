import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SemesterCard extends StatelessWidget {
  final Map<String, dynamic> semester; // Change type to Map<String, dynamic>

  const SemesterCard({
    super.key,
    required this.semester,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE3E3E3),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: ListTile(    
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "S.Y. ${semester['acad_year_start']} - ${semester['acad_year_end']}", // Access Map fields directly
              style: GoogleFonts.openSans(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF173F70),
              ),
            ),
            const SizedBox(height: 4),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${semester['sem_start_date']} - ${semester['sem_end_date']}",
              style: GoogleFonts.openSans(
                fontSize: 14,
                color: const Color(0xFF173F70),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "${semester['year_level']} - ${semester['semester']}",
                  style: GoogleFonts.openSans(
                    fontSize: 14,
                    color: const Color(0xFF173F70),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
