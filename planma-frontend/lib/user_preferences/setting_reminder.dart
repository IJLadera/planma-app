import 'package:flutter/material.dart';
import 'package:planma_app/core/dashboard.dart';
import 'package:planma_app/user_preferences/setting_goal.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:planma_app/Providers/user_preferences_provider.dart';

class SleepWakeReminderScreen extends StatefulWidget {
  final String usualSleepTime;
  final String usualWakeTime;

  const SleepWakeReminderScreen({
    super.key,
    required this.usualSleepTime,
    required this.usualWakeTime,
  });

  @override
  _SleepWakeReminderScreenState createState() =>
      _SleepWakeReminderScreenState();
}

class _SleepWakeReminderScreenState extends State<SleepWakeReminderScreen> {
  String _selectedTime = "01 h : 00 m"; // Default value for the dropdown

  // List of time options
  final List<String> _timeOptions = [
    "00 h : 30 m",
    "01 h : 00 m",
    "02 h : 00 m",
    "03 h : 00 m",
  ];

  Future<void> _saveReminderToDatabase(String reminderTime) async {
    final provider =
        Provider.of<UserPreferencesProvider>(context, listen: false);
    try {
      // Save the reminder time using the provider
      await provider.saveUserPreferences(
        usualSleepTime: widget.usualSleepTime,
        usualWakeTime: widget.usualWakeTime,
        reminderOffsetTime: reminderTime,
      );

      // If successful, show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Reminder saved successfully!")),
      );

      // Navigate to the next screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Dashboard(),
        ),
      );
    } catch (e) {
      // Handle error while saving reminder
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving reminder: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Set Sleep/Wake Reminder"),
        backgroundColor: Color(0xFF173F70),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Heading
              Text(
                "Let’s get you all\nset up!",
                textAlign: TextAlign.center,
                style: GoogleFonts.openSans(
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                "When should we give you a heads-up\nbefore each task?",
                textAlign: TextAlign.center,
                style: GoogleFonts.openSans(
                  fontSize: 16.0,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 40.0),
              Image.asset(
                'lib/user_preferences/assets/alarm.png',
                height: 120.0,
              ),
              SizedBox(height: 40.0),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: DropdownButton<String>(
                  value: _selectedTime,
                  isExpanded: true,
                  underline: SizedBox(),
                  items: _timeOptions
                      .map((time) => DropdownMenuItem<String>(
                            value: time,
                            child: Text(time),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedTime = value!;
                    });
                  },
                ),
              ),
              SizedBox(height: 40.0),
              // Next Button
              ElevatedButton(
                onPressed: () async {
                  // Save reminder to database using the provider
                  await _saveReminderToDatabase(_selectedTime);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF173F70),
                  padding:
                      EdgeInsets.symmetric(horizontal: 50.0, vertical: 18.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text(
                  "Next",
                  style: GoogleFonts.openSans(
                    fontSize: 18.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
