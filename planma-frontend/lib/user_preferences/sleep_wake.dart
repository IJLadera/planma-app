import 'package:flutter/material.dart';
import 'package:planma_app/Providers/user_preferences_provider.dart';
import 'package:planma_app/user_preferences/setting_reminder.dart';
import 'package:planma_app/user_preferences/widget/widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SleepWakeSetupScreen extends StatefulWidget {
  @override
  _SleepWakeSetupScreenState createState() => _SleepWakeSetupScreenState();
}

class _SleepWakeSetupScreenState extends State<SleepWakeSetupScreen> {
  TimeOfDay? sleepTime;
  TimeOfDay? wakeTime;

  String timeToString(TimeOfDay time) {
    final hours = time.hour.toString().padLeft(2, '0');
    final minutes = time.minute.toString().padLeft(2, '0');
    return '$hours:$minutes'; // Combine to "HH:mm"
  }

  Future<void> _selectTime(BuildContext context, bool isSleepTime) async {
    final TimeOfDay initialTime = isSleepTime
        ? sleepTime ??
            TimeOfDay(hour: 23, minute: 0) // Default to 11:00 PM if null
        : wakeTime ??
            TimeOfDay(hour: 7, minute: 0); // Default to 7:00 AM if null

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null) {
      setState(() {
        if (isSleepTime) {
          sleepTime = picked; // Update the sleep time
        } else {
          wakeTime = picked; // Update the wake time
        }
      });
    }
  }

  Future<void> _savePreferences() async {
    final provider =
        Provider.of<UserPreferencesProvider>(context, listen: false);

    try {
      // Ensure both times are selected before proceeding
      if (sleepTime == null || wakeTime == null) {
        throw Exception("Please set both sleep and wake times.");
      }

      // Save the user preferences using the provider
      await provider.saveUserPreferences(
        usualSleepTime: timeToString(sleepTime ??
            TimeOfDay(hour: 23, minute: 0)), // Default value if null
        usualWakeTime: timeToString(
            wakeTime ?? TimeOfDay(hour: 7, minute: 0)), // Default value if null
        reminderOffsetTime: "", // Assuming this is optional or empty
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Preferences saved successfully!")),
      );

      // Navigate to the next screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SleepWakeReminderScreen(
            usualSleepTime: timeToString(sleepTime!),
            usualWakeTime: timeToString(wakeTime!),
          ),
        ),
      );
    } catch (error) {
      // Handle error while saving preferences
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving preferences: $error")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Let’s set up your day!",
                style: GoogleFonts.openSans(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.0),
              Text(
                "Share your usual sleep and wake times",
                style: GoogleFonts.openSans(
                  fontSize: 16.0,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.0),
              Image.asset(
                'lib/user_preferences/assets/sleep.png',
                height: 120.0,
              ),
              SizedBox(height: 24.0),
              buildTimePickerField(
                context: context,
                label: "Usual Sleep Time",
                time: sleepTime ??
                    TimeOfDay(hour: 23, minute: 0), // Default value if null
                onTap: () => _selectTime(context, true),
              ),
              SizedBox(height: 16.0),
              buildTimePickerField(
                context: context,
                label: "Usual Wake Time",
                time: wakeTime ??
                    TimeOfDay(hour: 7, minute: 0), // Default value if null
                onTap: () => _selectTime(context, false),
              ),
              SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: _savePreferences, // Trigger saving preferences
                style: ElevatedButton.styleFrom(
                  padding:
                      EdgeInsets.symmetric(horizontal: 50.0, vertical: 18.0),
                  backgroundColor: Color(0xFF173F70),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text(
                  "Next",
                  style: GoogleFonts.openSans(
                    fontSize: 18.0,
                    color: Color(0xFFFFFFFF),
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
