import 'package:flutter/material.dart';
import 'package:planma_app/activities/edit_activity.dart';
import 'package:planma_app/activities/widget/activity_detail_screen.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts

class ViewActivity extends StatelessWidget {
  final String activityName;
  final String description;
  final String date;
  final String time;

  const ViewActivity({
    super.key,
    required this.activityName,
    required this.description,
    required this.date,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF173F70)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFF173F70)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditActivity(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Color(0xFF173F70)),
            onPressed: () {
              // Handle delete task logic
            },
          ),
        ],
        centerTitle: true,
        title: Text(
          'Activities',
          style: GoogleFonts.openSans(
            color: Color(0xFF173F70),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[100],
          ),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ActivityDetailsScreen(
                  title: 'Name:',
                  detail: activityName,
                  textStyle: GoogleFonts.openSans(fontSize: 16),
                ),
                const Divider(),
                ActivityDetailsScreen(
                  title: 'Description:',
                  detail: description,
                  textStyle: GoogleFonts.openSans(fontSize: 16),
                ),
                const Divider(),
                ActivityDetailsScreen(
                  title: 'Date:',
                  detail: date,
                  textStyle: GoogleFonts.openSans(fontSize: 16),
                ),
                const Divider(),
                ActivityDetailsScreen(
                  title: 'Time:',
                  detail: time,
                  textStyle: GoogleFonts.openSans(fontSize: 16),
                ),
                const Divider(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
