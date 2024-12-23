import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:planma_app/Front%20&%20back%20end%20connections/logout_service.dart';
import 'package:planma_app/authentication/log_in.dart';

class CustomWidget {
  static Widget buildTimePickerField({
    required BuildContext context,
    required String label,
    required TimeOfDay time,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 25.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: GoogleFonts.openSans(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: Colors.black,
              ),
            ),
            Spacer(),
            Text(
              '${time.format(context)}',
              style: GoogleFonts.openSans(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static TimeOfDay parseTimeOfDay(String timeString) {
    final parts = timeString.split(":");
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return TimeOfDay(hour: hour, minute: minute);
  }

  Duration parseReminderOffset(String reminderOffset) {
    final regex = RegExp(r"(\d+)\s*h\s*:\s*(\d+)\s*m");
    final match = regex.firstMatch(reminderOffset);

    if (match != null) {
      final int hours = int.parse(match.group(1)!);
      final int minutes = int.parse(match.group(2)!);

      return Duration(hours: hours, minutes: minutes);
    } else {
      throw FormatException("Invalid reminder offset format: $reminderOffset");
    }
  }

  static Future<void> logout(BuildContext context) async {
    final authLogout = AuthLogout();

    // Show a loading dialog
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissal by tapping outside
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("Logging out..."),
              ],
            ),
          ),
        );
      },
    );

    // Introduce an artificial delay (e.g., 2 seconds)
    await Future.delayed(Duration(seconds: 2));

    await authLogout.logOut();

    // Dismiss the loading dialog
    Navigator.pop(context);

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Logout successful")));
    // Successful logout, navigate to login screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LogIn()),
    );

    // if (response != null && response["error"] == null) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text("Logout successful"))
    //   );
    //   // Successful logout, navigate to login screen
    //   Navigator.pushReplacement(
    //       context,
    //       MaterialPageRoute(builder: (context) => LogIn()),
    //     );
    // } else {
    //   // Handle logout failure
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('Logout failed, please try again')),
    //   );
    // }
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

}


