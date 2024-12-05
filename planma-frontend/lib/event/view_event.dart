import 'package:flutter/material.dart';
import 'package:planma_app/event/edit_event.dart';
import 'package:planma_app/event/widget/event_detail_row.dart';
import 'package:planma_app/Front%20&%20back%20end%20connections/events_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:planma_app/event/widget/widget.dart';

class ViewEvent extends StatefulWidget {
  final String eventName;
  final String timePeriod;
  final String description;
  final String location;
  final String date;
  final String type;

  const ViewEvent({
    super.key,
    required this.eventName,
    required this.timePeriod,
    required this.description,
    required this.location,
    required this.date,
    required this.type,
  });

  @override
  _ViewEventState createState() => _ViewEventState();
}

class _ViewEventState extends State<ViewEvent> {
  String selectedAttendance = 'Did Not Attend';

  // Function to determine color based on the selected value
  Color getColor(String value) {
    switch (value) {
      case 'Did Not Attend':
        return Colors.red;
      case 'Excused':
        return Colors.blue;
      case 'Attended':
        return Colors.green;
      default:
        return Colors.grey; // Default for unselected
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.blue),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: Colors.blue),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditEvent()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.blue),
            onPressed: () {
              // Add delete functionality
            },
          ),
        ],
        centerTitle: true,
        title: Text(
          'Event',
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
            borderRadius: BorderRadius.circular(9),
            color: Colors.grey[100],
          ),
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EventDetailRow(
                  title: 'Title',
                  value: widget.eventName,
                ),
                const Divider(),
                EventDetailRow(
                  title: 'Description',
                  value: widget.description,
                ),
                const Divider(),
                EventDetailRow(
                  title: 'Location',
                  value: widget.location,
                ),
                const Divider(),
                EventDetailRow(
                  title: 'Date',
                  value: widget.date,
                ),
                const Divider(),
                EventDetailRow(
                  title: 'Time',
                  value: widget.timePeriod,
                ),
                const Divider(),
                EventDetailRow(
                  title: 'Type',
                  value: widget.type,
                ),
                const Divider(),
                SizedBox(height: 16),
                // Dropdown for attendance
                Text(
                  'Attendance',
                  style: GoogleFonts.openSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8),
                CustomWidgets.dropwDownForAttendance(
                    label: 'Attendance',
                    value: selectedAttendance,
                    items: ['Did Not Attend', 'Excused', 'Attended'],
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedAttendance = newValue; // Update the value
                        });
                      }
                    },
                    backgroundColor: Color(0XFFF5F5F5),
                    labelColor: Colors.black,
                    textColor: CustomWidgets.getColor(
                        selectedAttendance), // Use getColor as a static method
                    borderRadius: 8.0,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    fontSize: 14.0,
                  ),
                SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
