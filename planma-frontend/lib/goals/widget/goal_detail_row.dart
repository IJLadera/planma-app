import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GoalDetailRow extends StatelessWidget {
  final String label;
  final String? detail;

  const GoalDetailRow({
    super.key,
    required this.label,
    this.detail,
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
              label,
              style: GoogleFonts.openSans(
                fontSize: 14,
                color: Color(0xFF173F70),
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
          )
        ],
      ),
    );
  }
}
