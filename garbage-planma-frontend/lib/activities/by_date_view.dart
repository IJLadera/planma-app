import 'package:flutter/material.dart';
import 'package:planma_app/models/activity_model.dart';
import 'package:planma_app/activities/widget/activity_card.dart';
import 'package:google_fonts/google_fonts.dart';

class ByDateView extends StatelessWidget {
  final List<Activity> activityView;

  const ByDateView({super.key, required this.activityView});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Categorize activity
    final Map<String, List<Activity>> groupedActivity = {
      "Past": activityView.where((activity) => activity.scheduledDate.isBefore(today)).toList(),
      "Today": activityView.where((activity) => activity.scheduledDate.isAtSameMomentAs(today)).toList(),
      "Tomorrow": activityView
          .where((activity) => activity.scheduledDate.isAtSameMomentAs(today.add(const Duration(days: 1))))
          .toList(),
      "This Week": activityView.where((activity) {
        final weekEnd = today.add(Duration(days: 7 - today.weekday));
        return activity.scheduledDate.isAfter(today) &&
            activity.scheduledDate.isBefore(weekEnd) &&
            !activity.scheduledDate.isAtSameMomentAs(today.add(const Duration(days: 1)));
      }).toList(),
      "Future": activityView
          .where((activity) => activity.scheduledDate.isAfter(today.add(Duration(days: 7 - today.weekday))))
          .toList(),
    };

    return ListView(
      children: groupedActivity.entries.map((entry) {
        final category = entry.key;
        final activitys = entry.value;

        return activitys.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
                      child: Text(
                        category,
                        style: GoogleFonts.openSans(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: activitys.length,
                      itemBuilder: (context, idx) {
                        final activity = activitys[idx];
                        return SizedBox(
                          // height: 120,
                          child: ActivityCard(isByDate: true, activity: activity),
                        );
                      },
                    ),
                  ],
                ),
              )
            : Container();
      }).toList(),
    );
  }
}