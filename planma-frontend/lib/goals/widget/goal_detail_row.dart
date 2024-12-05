import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GoalDetailRow extends StatelessWidget {
  final String label;
  final String value;

  const GoalDetailRow({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.openSans(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF173F70),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.openSans(
              fontSize: 14,
              color: Color(0xFF173F70),
            ),
          ),
        ],
      ),
    );
  }
}
