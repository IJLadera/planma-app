import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:planma_app/Front%20&%20back%20end%20connections/logout_service.dart';
import 'package:planma_app/features/authentication/presentation/pages/log_in_page.dart';
import 'package:planma_app/features/authentication/presentation/providers/user_provider.dart';
import 'package:provider/provider.dart';

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
        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
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
    final userProvider = Provider.of<UserProvider>(context, listen: false);

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

    await userProvider.logout(context);

    // Dismiss the loading dialog
    Navigator.pop(context);

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Logout successful")));
    // Successful logout, navigate to login screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LogInPage()),
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

  static void showCustomSnackBar({
    required BuildContext context,
    required String message,
    required bool isSuccess,
  }) {
    final backgroundColor =
        isSuccess ? const Color(0xFF50B6FF).withOpacity(0.8) : Colors.red;

    final icon = isSuccess
        ? const Icon(Icons.check_circle, color: Colors.green, size: 20)
        : const Icon(Icons.error, color: Colors.white, size: 24);

    final snackBar = SnackBar(
      content: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.openSans(fontSize: 12, color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height * 0.4,
        left: 30,
        right: 30,
        top: 100,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: backgroundColor,
      elevation: 12,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
