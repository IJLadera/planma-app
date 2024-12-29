import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TaskDetailRow extends StatelessWidget {
  final String title;
  final dynamic detail;

  const TaskDetailRow({
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
                fontWeight: FontWeight.bold,
                color: const Color(0xFF173F70),
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              detail,
              style: GoogleFonts.openSans(
                color: const Color(0xFF173F70),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
