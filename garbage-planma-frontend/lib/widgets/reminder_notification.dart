/* // lib/widgets/reminder_notification.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:planma_app/Providers/web_socket_provider.dart';
import 'package:planma_app/reminder/task_reminder.dart';
import 'package:planma_app/reminder/event_reminder.dart';
import 'package:planma_app/reminder/goal_reminder.dart';
import 'package:planma_app/reminder/sleep_reminder.dart';
import 'package:planma_app/reminder/activity_reminder.dart';
import 'package:planma_app/reminder/class_reminder.dart';


class ReminderNotification extends StatelessWidget {
  const ReminderNotification({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final webSocketProvider = Provider.of<WebSocketProvider>(context);
    final reminder = webSocketProvider.latestReminder;

    if (reminder == null || !webSocketProvider.isShowingReminder) {
      return const SizedBox.shrink();
    }

    final message = reminder['message'] as String;
    final isSleepReminder = message.contains('sleep');

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSleepReminder
                  ? const Color(0xFF535D88)
                  : const Color(0xFF7DCFB6),
              width: 2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(
                      isSleepReminder ? Icons.nightlight_round : Icons.wb_sunny,
                      size: 32,
                      color: isSleepReminder
                          ? const Color(0xFF535D88)
                          : const Color(0xFF7DCFB6),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        message,
                        style: GoogleFonts.openSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF173F70),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      webSocketProvider.dismissReminder();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF173F70),
                    ),
                    child: Text(
                      'Dismiss',
                      style: GoogleFonts.openSans(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
 */