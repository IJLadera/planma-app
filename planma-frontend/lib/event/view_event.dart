import 'package:flutter/material.dart';
import 'package:planma_app/event/edit_event.dart';
import 'package:planma_app/event/widget/event_detail_row.dart';

class ViewEvent extends StatefulWidget {
  final String eventName;
  final String timePeriod;
  final String description;
  final String location;
  final String date;
  final String type;

  const ViewEvent({
    Key? key,
    required this.eventName,
    required this.timePeriod,
    required this.description,
    required this.location,
    required this.date,
    required this.type,
  }) : super(key: key);

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
          style: TextStyle(
            color: Colors.black,
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
                  title: 'Title',
                  value: widget.eventName,
                ),
                EventDetailRow(
                  title: 'Description',
                  value: widget.description,
                ),
                EventDetailRow(
                  title: 'Location',
                  value: widget.location,
                ),
                EventDetailRow(
                  title: 'Date',
                  value: widget.date,
                ),
                EventDetailRow(
                  title: 'Time',
                  value: widget.timePeriod,
                ),
                EventDetailRow(
                  title: 'Type',
                  value: widget.type,
                ),
                SizedBox(height: 16),
                // Dropdown for attendance
                Text(
                  'Attendance',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: getColor(selectedAttendance),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    value: selectedAttendance,
                    icon: Icon(Icons.arrow_drop_down),
                    isExpanded: true,
                    underline: SizedBox(), // Remove default underline
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedAttendance = newValue!;
                      });
                    },
                    items: <String>['Did Not Attend', 'Excused', 'Attended']
                        .map<DropdownMenuItem<String>>((String value) {
                      return new DropdownMenuItem<String>(
                        value: value,
                        child: Row(
                          children: [
                            Expanded(
                              child: new Text(
                                value,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: value == selectedAttendance
                                      ? getColor(value)
                                      : Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
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
