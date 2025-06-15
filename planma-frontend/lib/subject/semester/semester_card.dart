import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:planma_app/Providers/semester_provider.dart';
import 'package:planma_app/subject/semester/edit_semester.dart';
import 'package:provider/provider.dart';

class SemesterCard extends StatelessWidget {
  final Map<String, dynamic> semester; // Change type to Map<String, dynamic>

  const SemesterCard({
    super.key,
    required this.semester,
  });

  void _handleDelete(BuildContext context) async {
    final provider = Provider.of<SemesterProvider>(context, listen: false);
    final isConfirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Semester',
          style: GoogleFonts.openSans(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
        ),
        content: Text(
          'Are you sure you want to delete this semester?',
          style: GoogleFonts.openSans(fontSize: 16, color: Color(0xFF1D4E89)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel',
                style: GoogleFonts.openSans(
                    fontSize: 16, color: Color(0xFF1D4E89))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(
              'Delete',
              style:
                  GoogleFonts.openSans(fontSize: 16, color: Color(0xFF1D4E89)),
            ),
          ),
        ],
      ),
    );

    if (isConfirmed == true) {
      provider.deleteSemester(semester['semester_id']);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
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
                        builder: (context) => EditSemesterScreen(
                              semester: semester,
                            )));
              },
            ),
            IconButton(
              icon: Icon(Icons.delete,
                  color:
                      Color(0xFF840000)), // Delete icon with the correct color
              onPressed: () => _handleDelete(context),
            ),
          ],
        ),
      ),
    );
  }
}
