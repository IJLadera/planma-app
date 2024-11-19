import 'package:flutter/material.dart';
import 'package:planma_app/event/edit_event.dart';
import 'package:planma_app/event/widget/event_detail_row.dart';
import 'package:planma_app/Front%20&%20back%20end%20connections/events_service.dart';

class ViewEvent extends StatelessWidget {
  final String eventName;
  final String timePeriod;
  final String code;
  final String room;

  const ViewEvent({
    Key? key,
    required this.eventName,
    required this.timePeriod,
    required this.code,
    required this.room,
  }) : super(key: key);

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
                    value: eventName,
                  ),
                  EventDetailRow(
                    title: 'Code',
                    value: code,
                  ),
                  EventDetailRow(
                    title: 'Time',
                    value: timePeriod,
                  ),
                  EventDetailRow(
                    title: 'Room',
                    value: room,
                  ),
                ],
              ),
            )),
      ),
    );
  }
}
