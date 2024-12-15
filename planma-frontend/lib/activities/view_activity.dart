import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:planma_app/Providers/activity_provider.dart';
import 'package:planma_app/activities/edit_activity.dart';
import 'package:planma_app/activities/widget/activity_detail_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:planma_app/models/activity_model.dart';
import 'package:provider/provider.dart'; // Import Google Fonts

class ActivityDetailScreen extends StatefulWidget {
  final Activity activity;

  ActivityDetailScreen({
    super.key,
    required this.activity,
  });

  @override
  State<ActivityDetailScreen> createState() => _ActivityDetailScreenState();
}

class _ActivityDetailScreenState extends State<ActivityDetailScreen> {
  late ActivityProvider activityProvider;

  void _handleDelete(BuildContext context) async {
    final provider = Provider.of<ActivityProvider>(context, listen: false);
    final isConfirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Activity'),
        content: const Text('Are you sure you want to delete this activity?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (isConfirmed == true) {
      provider.deleteActivity(widget.activity.activityId!);
      Navigator.pop(context);
    }
  }

  String _formatTimeForDisplay(String time24) {
    final timeParts = time24.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    final timeOfDay = TimeOfDay(hour: hour, minute: minute);

    // Format to "H:mm a"
    final now = DateTime.now();
    final dateTime = DateTime(
      now.year,
      now.month,
      now.day,
      timeOfDay.hour,
      timeOfDay.minute,
    );
    return DateFormat.jm().format(dateTime);
  }

  String _formatScheduledDate(DateTime date) {
    return DateFormat('dd MMMM yyyy').format(date); // Example: 09 December 2024
  }

  String _formatDeadline(DateTime date) {
    return DateFormat('dd MMMM yyyy - hh:mm a')
        .format(date); // Example: 18 December 2024 - 12:00 AM
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ActivityProvider>(
        builder: (context, activityProvider, child) {
      final activity = activityProvider.activity.firstWhere(
        (activity) => activity.activityId == widget.activity.activityId,
        orElse: () => Activity(
          activityId: -1,
          activityName: 'N/A',
          activityDescription: 'N/A',
          scheduledDate: DateTime(2020, 1, 1),
          scheduledStartTime: '00:00',
          scheduledEndTime: '00:00',
        ),
      );

      if (activity.activityId == -1) {
        return Scaffold(
          appBar: AppBar(title: Text('Activity Details')),
          body: Center(child: Text('Activity not found')),
        );
      }

      final startTime = _formatTimeForDisplay(activity.scheduledStartTime);
      final endTime = _formatTimeForDisplay(activity.scheduledEndTime);
      final formattedScheduledDate =
          _formatScheduledDate(activity.scheduledDate);

      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Color(0xFF173F70)),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFF173F70)),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EditActivity(activity: activity,)),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Color(0xFF173F70)),
              onPressed: () => _handleDelete(context),
            ),
          ],
          centerTitle: true,
          title: Text(
            'Activity',
            style: GoogleFonts.openSans(
              color: Color(0xFF173F70),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[100],
            ),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ActivityDetailsScreen(
                    title: 'Name:',
                    detail: activity.activityName,
                    textStyle: GoogleFonts.openSans(fontSize: 16),
                  ),
                  const Divider(),
                  ActivityDetailsScreen(
                    title: 'Description:',
                    detail: activity.activityDescription,
                    textStyle: GoogleFonts.openSans(fontSize: 16),
                  ),
                  const Divider(),
                  ActivityDetailsScreen(
                    title: 'Date:',
                    detail: formattedScheduledDate.toString(),
                    textStyle: GoogleFonts.openSans(fontSize: 16),
                  ),
                  const Divider(),
                  ActivityDetailsScreen(
                    title: 'Time:',
                    detail: '$startTime - $endTime',
                    textStyle: GoogleFonts.openSans(fontSize: 16),
                  ),
                  const Divider(),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
