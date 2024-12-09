import 'package:flutter/material.dart';
import 'package:planma_app/Providers/user_preferences_provider.dart';
import 'package:planma_app/user_preferences/setting_reminder.dart';
import 'package:planma_app/user_preferences/widget/widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

// Ensure this code snippet is used alongside other fixed parts like buildTimePickerField

class SleepWakeSetupScreen extends StatefulWidget {

  @override
  _SleepWakeSetupScreenState createState() => _SleepWakeSetupScreenState();
}

class _SleepWakeSetupScreenState extends State<SleepWakeSetupScreen> {
  TimeOfDay sleepTime = TimeOfDay(hour: 23, minute: 0);
  TimeOfDay wakeTime = TimeOfDay(hour: 7, minute: 0);

  String timeToString(TimeOfDay time) {
    final hours = time.hour.toString().padLeft(2, '0');
    final minutes = time.minute.toString().padLeft(2, '0');
    return '$hours:$minutes'; // Combine to "HH:mm"
  }


  Future<void> _selectTime(BuildContext context, bool isSleepTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isSleepTime ? sleepTime : wakeTime,
    );
    if (picked != null) {
      setState(() {
        if (isSleepTime) {
          sleepTime = picked;
        } else {
          wakeTime = picked;
        }
      });
    }
  }

  // Save user preferences via the UserPreferencesProvider
  Future<void> _savePreferences() async {
    final provider =
        Provider.of<UserPreferencesProvider>(context, listen: false);

    
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
                time: sleepTime,
                onTap: () => _selectTime(context, true),
              ),
              SizedBox(height: 16.0),
              buildTimePickerField(
                context: context,
                label: "Usual Wake Time",
                time: wakeTime,
                onTap: () => _selectTime(context, false),
              ),
              SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: () {
                  // Handle next button action here
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SleepWakeReminderScreen(
                              usualSleepTime:
                                  "${sleepTime.hour}:${sleepTime.minute}",
                              usualWakeTime:
                                  "${wakeTime.hour}:${wakeTime.minute}",
                              studentId:
                                  1, // Replace with the actual student ID
                            )),
                  );
                },
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
