import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:planma_app/Providers/attended_events_provider.dart';
import 'package:planma_app/Providers/events_provider.dart';
import 'package:planma_app/event/edit_event.dart';
import 'package:planma_app/event/widget/event_detail_row.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:planma_app/event/widget/widget.dart';
import 'package:planma_app/models/attended_events_model.dart';
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
  bool isLoadingAttendance = true;

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
  void initState() {
    super.initState();
    _initializeAttendanceStatus();
  }

  // Fetch attendance status and update the dropdown
  void _initializeAttendanceStatus() async {
    final provider =
        Provider.of<AttendedEventsProvider>(context, listen: false);

    try {
      await provider.fetchAttendedEvents();

      // Check if the event has an attendance record
      final attendedEvent = provider.attendedEvents.firstWhere(
        (attendedEvent) =>
            attendedEvent.event?.eventId == widget.event.eventId &&
            attendedEvent.date ==
                DateFormat('yyyy-MM-dd').format(widget.event.scheduledDate),
        orElse: () => AttendedEvent(
          id: -1,
          event: null,
          date: '',
          hasAttended: false,
        ),
      );

      if (attendedEvent.id != -1) {
        setState(() {
          selectedAttendance =
              attendedEvent.hasAttended ? 'Attended' : 'Did Not Attend';
        });
      } else {
        print('No attendance record found for this event yet (Not an error).');
      }
    } catch (error) {
      print('Error fetching attendance status: $error');
    } finally {
      setState(() {
        isLoadingAttendance = false; // Attendance data is now loaded
      });
    }
  }

  void _handleAttendanceChange(String? newValue) async {
    if (newValue != null) {
      setState(() {
        selectedAttendance = newValue; // Update UI
      });

      // Convert selectedAttendance to a boolean
      bool hasAttended = newValue == 'Attended';

      try {
        final provider =
            Provider.of<AttendedEventsProvider>(context, listen: false);
        await provider.markAttendance(
          eventId: widget.event.eventId!,
          date: widget.event.scheduledDate,
          hasAttended: hasAttended,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Attendance marked as $newValue',
              style: GoogleFonts.openSans(fontSize: 14),
            ),
          ),
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to update attendance: $error',
              style: GoogleFonts.openSans(fontSize: 14),
            ),
          ),
        );
      }
    }
  }

  void _handleDelete(BuildContext context) async {
    final provider = Provider.of<EventsProvider>(context, listen: false);
    final isConfirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Event',
          style: GoogleFonts.openSans(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
        ),
        content: Text(
          'Are you sure you want to delete this event?',
          style: GoogleFonts.openSans(
            fontSize: 14,
            color: Color(0xFF1D4E89),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.openSans(
                fontSize: 16,
                color: Color(0xFF1D4E89),
              ),
            ),
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
              style: GoogleFonts.openSans(
                fontSize: 16,
                color: Color(0xFF1D4E89),
              ),
            ),
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
      );

      if (event.eventId == null) {
        return Scaffold(
          appBar: AppBar(title: Text('Event Details')),
          body: Center(child: Text('Event not found')),
        );
      }

      final startTime = _formatTimeForDisplay(event.scheduledStartTime);
      final endTime = _formatTimeForDisplay(event.scheduledEndTime);
      final formattedScheduledDate =
          DateFormat('dd MMMM yyyy').format(event.scheduledDate);
      // String currentDay = DateFormat('dd MMMM yyyy').format(DateTime.now());
      // bool isTodayEventDay = currentDay == formattedScheduledDate;
      bool isTodayOrPastEventDay = !event.scheduledDate.isAfter(DateTime.now());

      return Scaffold(
        backgroundColor: Color(0xFFFFFFFF),
        appBar: AppBar(
          backgroundColor: Color(0xFFFFFFFF),
          actions: [
            IconButton(
              icon: Icon(Icons.edit, color: Color(0xFF173F70)),
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
              icon: Icon(Icons.delete, color: Color(0xFF173F70)),
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
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  EventDetailRow(
                    title: 'Title:',
                    value: event.eventName,
                  ),
                  const Divider(),
                  EventDetailRow(
                    title: 'Description:',
                    value: event.eventDesc,
                  ),
                  const Divider(),
                  EventDetailRow(
                    title: 'Location:',
                    value: event.location,
                  ),
                  const Divider(),
                  EventDetailRow(
                    title: 'Date:',
                    value: formattedScheduledDate.toString(),
                  ),
                  const Divider(),
                  EventDetailRow(
                    title: 'Time:',
                    value: '$startTime - $endTime',
                  ),
                  const Divider(),
                  EventDetailRow(
                    title: 'Type:',
                    value: event.eventType,
                  ),
                  const Divider(),
                  SizedBox(height: 30),
                  // Show a loading indicator while attendance is being fetched
                  isLoadingAttendance
                      ? Center(child: CircularProgressIndicator())
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Text(
                                'Attendance',
                                style: GoogleFonts.openSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF173F70),
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            IgnorePointer(
                              ignoring:
                                  !isTodayOrPastEventDay, // Disable interaction if not today
                              child: Opacity(
                                opacity: isTodayOrPastEventDay
                                    ? 1.0
                                    : 0.5, // Greyed-out effect
                                child: CustomWidgets.dropwDownForAttendance(
                                  label: 'Attendance',
                                  value: selectedAttendance,
                                  items: ['Did Not Attend', 'Attended'],
                                  onChanged: _handleAttendanceChange,
                                  backgroundColor: Color(0XFFF5F5F5),
                                  labelColor: Colors.black,
                                  textColor: CustomWidgets.getColor(
                                      selectedAttendance),
                                  borderRadius: 8.0,
                                  fontSize: 14.0,
                                ),
                              ),
                            ),
                            if (!isTodayOrPastEventDay) ...[
                              SizedBox(height: 8),
                              Center(
                                child: Text(
                                  "You can only log attendance on the scheduled day or after.",
                                  style: GoogleFonts.openSans(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                    fontStyle: FontStyle.italic,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ]
                          ],
                        ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
