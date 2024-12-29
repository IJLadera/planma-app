import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:planma_app/subject/semester/edit_semester.dart';

class SemesterCard extends StatelessWidget {
  final String title;
  final String dateRange;
  final String yearLevel; // Changed to yearLevel
  final String semester;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const SemesterCard({
    Key? key,
    required this.title,
    required this.dateRange,
    required this.yearLevel, // Modified to yearLevel
    required this.semester,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Color(0xFFE3E3E3),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.openSans(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF173F70),
              ),
            ),
            SizedBox(height: 4), // Adds space between title and subtitle
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dateRange,
              style: GoogleFonts.openSans(
                fontSize: 14,
                color: Color(0xFF173F70),
              ),
            ),
            SizedBox(height: 4), // Adds space between dateRange and row
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "$yearLevel - $semester", // Concatenate yearLevel and semester
                  style: GoogleFonts.openSans(
                    fontSize: 14,
                    color: Color(0xFF173F70),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit,
                  color: Color(0xFF173F70)), // Edit icon with the correct color
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => EditSemesterScreen()));
              },
            ),
            IconButton(
              icon: Icon(Icons.delete,
                  color:
                      Color(0xFF840000)), // Delete icon with the correct color
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
