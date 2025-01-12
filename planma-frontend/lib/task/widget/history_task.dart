import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HistoryTaskScreen extends StatelessWidget {
  const HistoryTaskScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'History',
          style: GoogleFonts.openSans(
            fontWeight: FontWeight.bold,
            color: Color(0xFF173F70),
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Color(0xFF173F70)),
      ),
      body: ListView.builder(
        itemCount: 5, // Placeholder for 5 history items
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.all(10),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              leading: CircleAvatar(
                radius: 25,
                backgroundColor: Colors.blueAccent,
                child: Icon(
                  Icons.event,
                  color: Colors.white,
                ),
              ),
              title: Text(
                'Activity Title $index',
                style: GoogleFonts.openSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                'Activity Date: 2025-01-01',
                style: GoogleFonts.openSans(color: Colors.grey),
              ),
              trailing: Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () {
                // Placeholder for interaction
                print('Tapped on event $index');
              },
            ),
          );
        },
      ),
    );
  }
}
