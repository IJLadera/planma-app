import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:planma_app/Providers/events_provider.dart';
import 'package:planma_app/event/edit_event.dart';
import 'package:planma_app/event/widget/event_detail_row.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:planma_app/event/widget/widget.dart';
import 'package:planma_app/models/events_model.dart';
import 'package:provider/provider.dart';

class EventDetailScreen extends StatefulWidget {
  final Event event;

  const EventDetailScreen({
    super.key,
    required this.event,
  });

  @override
  _EventDetailScreenState createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  String selectedAttendance = 'Did Not Attend';
  late EventsProvider eventProvider;

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

  void _handleDelete(BuildContext context) async {
    final provider = Provider.of<EventsProvider>(context, listen: false);
    final isConfirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: const Text('Are you sure you want to delete this event?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (isConfirmed == true) {
      provider.deleteEvent(widget.event.eventId!);
      Navigator.pop(context);
    }
  }

  String _formatTimeForDisplay(String time24) {
    final timeParts = time24.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    final timeOfDay = TimeOfDay(hour: hour, minute: minute);

    // Format to "H:mm a"
    final now = DateTime.now();
    final dateTime = DateTime(
      now.year,
      now.month,
      now.day,
      timeOfDay.hour,
      timeOfDay.minute,
    );
    return DateFormat.jm().format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EventsProvider>(builder: (context, eventProvider, child) {
      final event = eventProvider.events.firstWhere(
        (event) => event.eventId == widget.event.eventId,
        orElse: () => Event(
          eventId: -1,
          eventName: 'N/A',
          eventDesc: 'N/A',
          location: 'N/A',
          scheduledDate: DateTime(2020, 1, 1),
          scheduledStartTime: '00:00',
          scheduledEndTime: '00:00',
          eventType: 'N/A',
        ),
      );
      print("event.eventId: ${event.eventId}");
      print("widget.eventId: ${widget.event.eventId}");
      print("widget.event: ${widget.event}");

      if (event.eventId == -1) {
        return Scaffold(
          appBar: AppBar(title: Text('Event Details')),
          body: Center(child: Text('Event not found')),
        );
      }

      final startTime = _formatTimeForDisplay(event.scheduledStartTime);
      final endTime = _formatTimeForDisplay(event.scheduledEndTime);
      final formattedScheduledDate =
          DateFormat('dd MMMM yyyy').format(event.scheduledDate);

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
                  MaterialPageRoute(
                      builder: (context) => EditEvent(
                            event: event,
                          )),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.blue),
              onPressed: () => _handleDelete(context),
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
                    value: event.eventName,
                  ),
                  const Divider(),
                  EventDetailRow(
                    title: 'Description',
                    value: event.eventDesc,
                  ),
                  const Divider(),
                  EventDetailRow(
                    title: 'Location',
                    value: event.location,
                  ),
                  const Divider(),
                  EventDetailRow(
                    title: 'Date',
                    value: formattedScheduledDate.toString(),
                  ),
                  const Divider(),
                  EventDetailRow(
                    title: 'Time',
                    value: '$startTime - $endTime',
                  ),
                  const Divider(),
                  EventDetailRow(
                    title: 'Type',
                    value: event.eventType,
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
                    fontSize: 14.0,
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
