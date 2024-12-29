import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:planma_app/Front%20&%20back%20end%20connections/logout_service.dart';
import 'package:planma_app/Providers/user_preferences_provider.dart';
import 'package:planma_app/Providers/user_provider.dart';
import 'package:planma_app/Providers/userprof_provider.dart';
import 'package:planma_app/authentication/log_in.dart';
import 'package:planma_app/user_profiile/edit_user.dart';
import 'package:planma_app/user_profiile/widget/widget.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  TimeOfDay? sleepTime;
  TimeOfDay? wakeTime;
  final List<String> _timeOptions = [
    "00 h : 30 m",
    "01 h : 00 m",
    "02 h : 00 m",
  ];
  String _selectedTime = "01 h : 00 m"; // Default value for the dropdown
  String? reminderOffsetTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await context.read<UserPreferencesProvider>().fetchUserPreferences();
        final userPreferences =
            context.read<UserPreferencesProvider>().userPreferences;
        if (userPreferences.isNotEmpty) {
          setState(() {
            sleepTime =
                CustomWidget.parseTimeOfDay(userPreferences[0].usualSleepTime);
            wakeTime =
                CustomWidget.parseTimeOfDay(userPreferences[0].usualWakeTime);
            reminderOffsetTime = userPreferences[0].reminderOffsetTime;
          });
        }
      } catch (error) {
        print('Error fetching preferences: $error'); // Debugging line
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error fetching preferences: $error")),
        );
      }
    });
  }

// Helper method to parse time string into TimeOfDay

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

  Future<void> _showTimePickerDialog(
      BuildContext context, UserPreferencesProvider provider) async {
    // Show dialog with Sleep and Wake time options
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Change Sleep & Wake Time',
            textAlign: TextAlign.center,
            style: GoogleFonts.openSans(
                fontSize: 24, // Increased font size for the title
                color: Color(0xFF173F70),
                fontWeight: FontWeight.bold),
          ),
          content: Container(
            height: 200, // Increased height for better space
            width: 250, // Increased width for better space
            padding: EdgeInsets.symmetric(horizontal: 5.0), // Added padding
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 20),
                CustomWidget.buildTimePickerField(
                  context: context,
                  label: "Usual Sleep Time",
                  time: sleepTime ?? TimeOfDay(hour: 23, minute: 0),
                  onTap: () =>
                      _selectTime(context, true), // true for sleep time
                ),
                const SizedBox(height: 30), // Increased space between fields
                // Wake Time Picker
                CustomWidget.buildTimePickerField(
                  context: context,
                  label: "Usual Wake Time",
                  time: wakeTime ?? TimeOfDay(hour: 7, minute: 0),
                  onTap: () => _selectTime(
                    context,
                    false,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            // Cancel Button
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.openSans(
                    fontSize: 14, color: Color(0xFF173F70)),
              ),
            ),
            // Save Button
            TextButton(
              onPressed: () async {
                // await saveUserPreferences(); // Save preferences
                Navigator.of(context).pop(); // Close the dialog after saving
              },
              child: Text(
                'Save',
                style: GoogleFonts.openSans(
                    fontSize: 14, color: Color(0xFF173F70)),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showOffsetReminderDialog(BuildContext context) async {
    String _tempSelectedTime = _selectedTime;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Select Reminder Offset',
            textAlign: TextAlign.center,
            style: GoogleFonts.openSans(
              fontSize: 24,
              color: Color(0xFF173F70),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Container(
            height: 250,
            width: 350,
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _timeOptions.length,
                    itemBuilder: (context, index) {
                      return RadioListTile<String>(
                        title: Text(
                          _timeOptions[index],
                          style: GoogleFonts.openSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        value: _timeOptions[index],
                        groupValue: _tempSelectedTime,
                        onChanged: (value) {
                          setState(() {
                            _tempSelectedTime = value ?? '';
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedTime = _tempSelectedTime;
                });
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                'OK',
                style: GoogleFonts.openSans(
                  fontSize: 18,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.openSans(
                  fontSize: 18,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String? username = context.watch<UserProfileProvider>().username;
    String? firstName = context.watch<UserProfileProvider>().firstName;
    String? lastName = context.watch<UserProfileProvider>().lastName;
    final userPreferencesProvider = context.watch<UserPreferencesProvider>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'User Profile',
          style: GoogleFonts.openSans(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF173F70),
          ),
        ),
        backgroundColor: Color(0xFFFFFFFF),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.yellow,
              child: Icon(
                Icons.person,
                size: 50,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 10),
            Text(
              username!,
              style: GoogleFonts.openSans(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '$firstName $lastName',
              style: GoogleFonts.openSans(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final updatedData = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfileScreen(
                      username: username!,
                      firstName: firstName!,
                      lastName: lastName!,
                    ),
                  ),
                );

                if (updatedData != null) {
                  setState(() {
                    username = updatedData['username'];
                    firstName = updatedData['firstName'];
                    lastName = updatedData['lastName'];
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF173F70),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      12), // Match TextFormField's border radius
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 60, vertical: 15), // Match horizontal padding
              ),
              child: Text(
                'Edit Profile',
                style: GoogleFonts.openSans(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 30),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: Icon(Icons.schedule),
                    title: Text('Sleep & Wake Time'),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      _showTimePickerDialog(context, userPreferencesProvider);
                    },
                  ),
                  SizedBox(height: 10),
                  ListTile(
                    leading: Icon(Icons.alarm),
                    title: Text('Reminder Offset'),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      _showOffsetReminderDialog(context);
                    },
                  ),
                ],
              ),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout, color: Color(0xFFEF4738)),
              title: Text(
                'Logout',
                style: TextStyle(color: Color(0xFFEF4738)),
              ),
              onTap: () {
                CustomWidget.logout(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
