import 'package:flutter/material.dart';
import 'package:planma_app/Providers/activity_provider.dart';
import 'package:planma_app/activities/by_date_view.dart';
import 'package:planma_app/activities/create_activity.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:planma_app/activities/widget/history_activity.dart';
import 'package:planma_app/activities/widget/search_bar.dart';
import 'package:provider/provider.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  _ActivityPageState createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  bool isByDate = true;

  @override
  void initState() {
    super.initState();
    final activityProvider =
        Provider.of<ActivityProvider>(context, listen: false);
    // Automatically fetch activitys when screen loads
    activityProvider.fetchActivity();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ActivityProvider>(
        builder: (context, activityProvider, child) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Activity',
            style: GoogleFonts.openSans(
                fontWeight: FontWeight.bold, color: Color(0xFF173F70)),
          ),
          backgroundColor: Color(0xFFFFFFFF),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: IconButton(
                icon: Icon(Icons.history, color: Color(0xFF173F70), size: 28.0),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HistoryActivityScreen()),
                  );
                },
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: Row(
                children: [
                  Expanded(child: CustomSearchBar()),
                  const SizedBox(width: 8),
                  PopupMenuButton(
                    icon: const Icon(Icons.filter_list, color: Colors.black),
                    onSelected: (value) {
                      setState(() {
                        isByDate = value == 'By Date';
                      });
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'By Date',
                        child: Text(
                          'By Date',
                          style: GoogleFonts.openSans(color: Colors.black),
                        ),
                      ),
                      PopupMenuItem(
                        value: 'By Subject',
                        child: Text(
                          'By Subject',
                          style: GoogleFonts.openSans(color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.history,
                        color: Color(0xFF173F70), size: 28.0),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => HistoryActivityScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: activityProvider.activity.isEmpty
                  ? Center(
                      child: Text(
                        'No activity added yet',
                        style: GoogleFonts.openSans(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    )
                  : ByDateView(
                      activityView: activityProvider.activity,
                    ),
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const AddActivityScreen()),
            );
          },
          backgroundColor: const Color(0xFF173F70),
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      );
    });
  }
}
