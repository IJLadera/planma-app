// subject_detail_row.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SubjectDetailRow extends StatelessWidget {
  final String title;
  final String detail;

  const SubjectDetailRow({
    super.key,
    required this.title,
    required this.detail,
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
                fontSize: 14,
                color: Color(0xFF173F70),
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              detail,
              style: GoogleFonts.openSans(
                color: Color(0xFF173F70),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
