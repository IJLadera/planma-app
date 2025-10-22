import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:planma_app/Providers/activity_provider.dart';
import 'package:planma_app/activities/view_activity.dart';
import 'package:provider/provider.dart';

class HistoryActivityScreen extends StatefulWidget {
  const HistoryActivityScreen({super.key});

  @override
  State<HistoryActivityScreen> createState() => _HistoryActivityScreenState();
}

class _HistoryActivityScreenState extends State<HistoryActivityScreen> {
  @override
  void initState() {
    super.initState();
    final activityProvider = Provider.of<ActivityProvider>(context, listen: false);
    // Automatically fetch activities when screen loads
    activityProvider.fetchCompletedActivities();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ActivityProvider>(
        builder: (context, activityProvider, child) {
      final activities = activityProvider.completedActivities;

      return Scaffold(
        appBar: AppBar(
          title: Text(
            'History',
            style: GoogleFonts.openSans(
              fontWeight: FontWeight.bold,
              color: Color(0xFF173F70),
            ),
          ),
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Color(0xFF173F70)),
        ),
        body: activities.isEmpty
            ? Center(
                child: Text(
                  'No completed activities yet.',
                  style: GoogleFonts.openSans(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              )
            : ListView.builder(
                itemCount: activities.length,
                itemBuilder: (context, index) {
                  final activity = activities[index];
                  final formattedDate = DateFormat('dd MMMM yyyy')
                      .format(activity.scheduledDate)
                      .toString();
                  return Card(
                    margin: const EdgeInsets.all(10),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.blueAccent,
                        child: Icon(
                          Icons.event,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        activity.activityName,
                        style: GoogleFonts.openSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        'Activity Date: $formattedDate',
                        style: GoogleFonts.openSans(color: Colors.grey),
                      ),
                      trailing: Icon(Icons.chevron_right, color: Colors.grey),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ActivityDetailScreen(activity: activity),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
      );
    });
  }
}
