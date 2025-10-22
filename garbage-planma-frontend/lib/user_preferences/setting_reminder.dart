import 'package:flutter/material.dart';
import 'package:planma_app/core/dashboard.dart';
import 'package:planma_app/user_preferences/create_semester.dart';
import 'package:planma_app/user_preferences/setting_goal.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:planma_app/user_preferences/widget/widget.dart';
import 'package:provider/provider.dart';
import 'package:planma_app/Providers/user_preferences_provider.dart';

class ReminderOffsetSetupScreen extends StatefulWidget {
  final TimeOfDay usualSleepTime;
  final TimeOfDay usualWakeTime;

  const ReminderOffsetSetupScreen({
    super.key,
    required this.usualSleepTime,
    required this.usualWakeTime,
  });

  @override
  _ReminderOffsetSetupScreenState createState() =>
      _ReminderOffsetSetupScreenState();
}

class _ReminderOffsetSetupScreenState extends State<ReminderOffsetSetupScreen> {
  String _selectedTime = "01 h : 00 m"; // Default value for the dropdown

  // List of time options
  final List<String> _timeOptions = [
    "00 h : 30 m",
    "01 h : 00 m",
    "02 h : 00 m",
  ];

  Future<void> _saveReminderToDatabase(String reminderTime) async {
    final provider =
        Provider.of<UserPreferencesProvider>(context, listen: false);

    final reminderOffsetDuration = provider.parseReminderOffset(reminderTime);
    final reminderOffsetTimeString = reminderOffsetDuration.inSeconds
        .toString(); // Convert to seconds for storage

    try {
      // Save the reminder time using the provider
      await provider.saveUserPreferences(
        usualSleepTime: widget.usualSleepTime,
        usualWakeTime: widget.usualWakeTime,
        reminderOffsetTime: reminderOffsetTimeString,
      );

      // If successful, show a success message
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text("Reminder saved successfully!")),
      // );

      // Navigate to the next screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PlanSemesterPage(),
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
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Let’s get you all\nset up!",
                textAlign: TextAlign.center,
                style: GoogleFonts.openSans(
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16.0),
              Text(
                "When should we give you a heads-up\nbefore each task?",
                textAlign: TextAlign.center,
                style: GoogleFonts.openSans(
                  fontSize: 16.0,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 30.0),
              Image.asset(
                'lib/user_preferences/assets/alarm.png',
                height: 120.0,
              ),
              const SizedBox(height: 30.0),
              Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 8.0), // Reduced padding
                child: CustomWidget.buildDropdownField(
                  label: '',
                  value: _selectedTime, // Current selected value
                  items: _timeOptions,
                  onChanged: (value) {
                    setState(() {
                      _selectedTime = value!;
                    });
                  },
                  borderRadius: 8.0,
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 2.0, horizontal: 10.0),
                  fontSize: 16.0,
                  textStyle:
                      GoogleFonts.openSans(color: const Color(0xFF173F70)),
                ),
              ),

              const SizedBox(height: 40.0),
              // Next Button
              ElevatedButton(
                onPressed: () async {
                  // Save reminder to database using the provider
                  await _saveReminderToDatabase(_selectedTime);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF173F70),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 110.0, vertical: 15.0),
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
