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
                    eventName: 'Date with GF',
                    description: 'Monthsary Date',
                    location: 'SM Downtown',
                    date: '11 January 2024',
                    timePeriod: '11:00 AM - 12:30 PM',
                    type: 'Academic',
                  ),
                  EventCard(
                    eventName: 'Date with GF',
                    description: 'Monthsary Date',
                    location: 'SM Downtown',
                    date: '11 January 2024',
                    timePeriod: '11:00 AM - 12:30 PM',
                    type: 'Academic',
                  ),
                  SectionTitle(title: 'December 18'),
                  EventCard(
                    eventName: 'Date with GF',
                    description: 'Monthsary Date',
                    location: 'SM Downtown',
                    date: '11 January 2024',
                    timePeriod: '11:00 AM - 12:30 PM',
                    type: 'Academic',
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
