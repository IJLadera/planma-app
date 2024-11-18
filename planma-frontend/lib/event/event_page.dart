import 'package:flutter/material.dart';
import 'package:planma_app/event/create_event.dart';
import 'package:planma_app/event/widget/event_card.dart';
import 'package:planma_app/event/widget/section_title.dart';

class EventsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Events'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  SectionTitle(title: 'Today'),
                  EventCard(
                    eventName: 'Physics I',
                    timePeriod: '11:00 AM - 12:30 PM',
                    code: 'PHYS102',
                    room: 'N/A',
                  ),
                  EventCard(
                    eventName: 'Chemistry II',
                    timePeriod: '1:00 PM - 2:30 PM',
                    code: 'CHEM202',
                    room: 'Room 5A',
                  ),
                  SectionTitle(title: 'December 18'),
                  EventCard(
                    eventName: 'Math III',
                    timePeriod: '10:00 AM - 11:30 AM',
                    code: 'MATH301',
                    room: 'Room   3B',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddEventState()),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Color(0xFF173F70),
      ),
    );
  }
}
