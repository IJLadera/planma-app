import 'package:flutter/material.dart';

class ActivityReminder extends StatelessWidget {
  final String activityName;
  //final Function(String response) onResponse;

  const ActivityReminder({
    super.key,
    required this.activityName,
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
          Image.asset(
            'lib/reminder/assests/puzzle-pieces.png',
            width: 48,
            height: 48,
          ),
          const Text(
            'Reminder',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
              children: [
                const TextSpan(text: "It's time for your activity: \n"),
                TextSpan(
                  text: activityName,
                  style:
                      const TextStyle(fontWeight: FontWeight.bold, height: 2.0),
                ),
                const TextSpan(
                    text: "\nReady to start?", style: TextStyle(height: 1.5)),
              ],
            ),
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
                  'Not Now',
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
