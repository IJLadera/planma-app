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
  // String? _selectedTime; // Default value for the dropdown
  String? reminderOffsetTime;

  String formatReminderOffset(String time) {
    final parts = time.split(':'); // Split "01:00:00" into ["01", "00", "00"]
    final hours = parts[0];
    final minutes = parts[1];
    return "${hours.padLeft(2, '0')} h : ${minutes.padLeft(2, '0')} m";
  }

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
            sleepTime = CustomWidget.parseTimeOfDay(userPreferences[0].usualSleepTime);
            wakeTime = CustomWidget.parseTimeOfDay(userPreferences[0].usualWakeTime);
            reminderOffsetTime = formatReminderOffset(userPreferences[0].reminderOffsetTime);
            print('Reminder Time: $reminderOffsetTime');
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

  Future<void> _showTimePickerDialog(
      BuildContext context, UserPreferencesProvider provider) async {
    // Show dialog with Sleep and Wake time options
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          // Use StatefulBuilder to update the dialog's state
          builder: (BuildContext context, StateSetter setDialogState) {
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
                width: 350, // Increased width for better space
                padding: EdgeInsets.symmetric(horizontal: 5.0), // Added padding
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 20),
                    CustomWidget.buildTimePickerField(
                      context: context,
                      label: "Usual Sleep Time",
                      time: sleepTime!, // Reference updated sleepTime
                      onTap: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: sleepTime!,
                        );
                        if (picked != null) {
                          setState(() {
                            sleepTime = picked; // Update main state
                          });
                          setDialogState(() {
                            // Update dialog state to reflect changes
                            sleepTime = picked;
                          });
                        }
                      },
                    ),
                    const SizedBox(
                        height: 30), // Increased space between fields
                    // Wake Time Picker
                    CustomWidget.buildTimePickerField(
                      context: context,
                      label: "Usual Wake Time",
                      time: wakeTime!, // Reference updated wakeTime
                      onTap: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: wakeTime!,
                        );
                        if (picked != null) {
                          setState(() {
                            wakeTime = picked; // Update main state
                          });
                          setDialogState(() {
                            // Update dialog state to reflect changes
                            wakeTime = picked;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                // Cancel Button
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
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
                    final prefId = provider.userPreferences[0].prefId;

                    if (prefId != null) {
                      await provider.saveSleepWakeTimes(
                        usualSleepTime: sleepTime!,
                        usualWakeTime: wakeTime!,
                        prefId: prefId,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text("Sleep/Wake times updated successfully")),
                      );
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text(
                    'Save',
                    style: GoogleFonts.openSans(
                      fontSize: 14,
                      color: Color(0xFF173F70),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showOffsetReminderDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Change Reminder Offset',
                textAlign: TextAlign.center,
                style: GoogleFonts.openSans(
                  fontSize: 24,
                  color: Color(0xFF173F70),
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Container(
                height: 150,
                width: 250,
                padding: EdgeInsets.symmetric(horizontal: 10.0),
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
                            groupValue: reminderOffsetTime,
                            onChanged: (value) {
                              setState(() {
                                reminderOffsetTime = value ?? '';
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
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.openSans(
                      fontSize: 14,
                      color: Color(0xFF173F70),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final provider = context.read<UserPreferencesProvider>();
                    final prefId = provider.userPreferences.isNotEmpty
                        ? provider.userPreferences[0].prefId
                        : null;

                    final reminderOffsetDuration = provider.parseReminderOffset(reminderOffsetTime!);
                    final reminderOffsetTimeString = reminderOffsetDuration.inSeconds.toString();

                    try {
                      await provider.saveReminderOffsetTime(
                        reminderOffsetTime: reminderOffsetTimeString,
                        prefId: prefId!,
                      );
                      print(
                          "New Reminder Offset Time: $reminderOffsetTimeString");
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                "Reminder offset time updated successfully")),
                      );
                      Navigator.of(context).pop();
                    } catch (error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text("Failed to update reminder offset time")),
                      );
                    }
                  },
                  child: Text(
                    'Save',
                    style: GoogleFonts.openSans(
                      fontSize: 14,
                      color: Color(0xFF173F70),
                    ),
                  ),
                ),
              ],
            );
          },
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
              username ??
                  'Guest', // Use 'Guest' as a fallback if username is null
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
