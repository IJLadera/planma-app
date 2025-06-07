import 'package:flutter/material.dart';

class EventReminder extends StatelessWidget {
  final String eventName; // Event name passed dynamically
  //final Function(String response) onResponse; // Callback for response handling

  const EventReminder({
    super.key,
    required this.eventName,
    //required this.onResponse,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: const EdgeInsets.all(16),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Calendar Icon
          Image.asset(
            'lib/reminder/assets/calendar.png', 
            width: 48, 
            height: 48, 
          ),
          const SizedBox(height: 16),
          // Reminder Title
          const Text(
            'Reminder',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          // Event Name and Message
          Text(
            '$eventName is happening now.\nAre you joining?',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          // Buttons Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // No Button
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  //onResponse('No'); // Pass "No" response
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Color(0xFFEF4738),
                  side: const BorderSide(color: Color(0xFFEF4738)),
                  minimumSize: const Size(80, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'No',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              // Yes Button
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  //onResponse('Yes'); // Pass "Yes" response
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF32C652),
                  minimumSize: const Size(80, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Yes',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
