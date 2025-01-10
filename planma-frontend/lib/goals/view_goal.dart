import 'package:flutter/material.dart';
import 'package:planma_app/Providers/goal_provider.dart';
import 'package:planma_app/Providers/goal_schedule_provider.dart';
import 'package:planma_app/Providers/semester_provider.dart';
import 'package:planma_app/goals/edit_goal.dart';
import 'package:planma_app/goals/add_goal_session.dart';
import 'package:planma_app/goals/widget/goal_detail_row.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:planma_app/goals/widget/goal_session_card.dart';
import 'package:planma_app/models/goals_model.dart';
import 'package:provider/provider.dart';

class GoalDetailScreen extends StatefulWidget {
  final Goal goal;

  const GoalDetailScreen({super.key, required this.goal});

  @override
  State<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends State<GoalDetailScreen> {
  String semesterDetails = 'Loading...';

  @override
  void initState() {
    super.initState();
    _fetchSemesterDetails();
    _fetchGoalSessions();
  }

  Future<void> _fetchSemesterDetails() async {
    final goal = Provider.of<GoalProvider>(context, listen: false)
        .goals
        .firstWhere((g) => g.goalId == widget.goal.goalId);

    if (goal.semester == null) {
      setState(() {
        semesterDetails = "N/A (Personal Goal)";
      });
      return;
    }

    final semesterProvider =
        Provider.of<SemesterProvider>(context, listen: false);
    try {
      final semester =
          await semesterProvider.getSemesterDetails(goal.semester!);
      setState(() {
        semesterDetails =
            "${semester?['acad_year_start']} - ${semester?['acad_year_end']} ${semester?['semester']}";
      });
    } catch (e) {
      setState(() {
        semesterDetails = 'Error fetching semester details';
      });
    }
  }

  Future<void> _fetchGoalSessions() async {
    final scheduleProvider =
        Provider.of<GoalScheduleProvider>(context, listen: false);
    await scheduleProvider.fetchGoalSchedulesPerGoal(widget.goal.goalId!);
  }

  void _handleDelete(BuildContext context) async {
    final provider = Provider.of<GoalProvider>(context, listen: false);
    final isConfirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Goal'),
        content: const Text('Are you sure you want to delete this goal?'),
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
      provider.deleteGoal(widget.goal.goalId!);
      Navigator.pop(context);
    }
  }



  @override
  Widget build(BuildContext context) {
    return Consumer3<GoalProvider, SemesterProvider, GoalScheduleProvider>(
        builder: (context, goalProvider, semesterProvider, scheduleProvider, child) {
      // Dynamically fetch the updated goal
      final goal =
          goalProvider.goals.firstWhere((g) => g.goalId == widget.goal.goalId);

      final sessions = scheduleProvider.goalschedules
          .where((s) => s.goal?.goalId == widget.goal.goalId)
          .toList();

      // print("Sessions xd: $sessions");

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
              onPressed: () {
                Navigator.push(context,MaterialPageRoute(
                    builder: (context) => EditGoal(goal: goal),
                  ),
                ).then((updated) {
                  if (updated == true) {
                    _fetchSemesterDetails(); // Refresh semester details
                    _fetchGoalSessions();
                  }
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Color(0xFF173F70)),
              onPressed: () => _handleDelete(context),
            ),
          ],
          centerTitle: true,
          title: Text(
            'Goal',
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
              borderRadius: BorderRadius.circular(9),
              color: Colors.grey[100],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GoalDetailRow(label: 'Name:', detail: goal.goalName),
                  const Divider(),
                  GoalDetailRow(label: 'Description:', detail: goal.goalDescription),
                  const Divider(),
                  GoalDetailRow(label: 'Timeframe:', detail: goal.timeframe),
                  const Divider(),
                  GoalDetailRow(label: 'Target Hours:', detail: goal.targetHours.toString()),
                  const Divider(),
                  GoalDetailRow(label: 'Type:', detail: goal.goalType),
                  const Divider(),
                  if (goal.goalType == 'Academic') ...[
                    GoalDetailRow(label: 'Semester:', detail: semesterDetails,),
                    const Divider(),
                  ],
                  const SizedBox(height: 16),
                  Text(
                    'Sessions',
                    style: GoogleFonts.openSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF173F70),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  sessions.isNotEmpty
                      ? ListView.builder(
                          shrinkWrap: true,
                          itemCount: sessions.length,
                          itemBuilder: (context, index) {
                            final session = sessions[index];
                            return GoalSessionCard(session: session);
                          },
                        )
                      : Center(
                          child: Text(
                            'No sessions added yet.',
                            style: GoogleFonts.openSans(color: const Color(0xFF173F70)),
                          ),
                        ),
                  SizedBox(height: 12),
                  // Add Session Button
                  Align(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(context,MaterialPageRoute(
                            builder: (context) => AddGoalSession(
                              goalName: goal.goalName,
                              goalId: goal.goalId!
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFB8B8B8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      ),
                      child: Text(
                        'Add Session',
                        style: GoogleFonts.openSans(
                          fontSize: 16,
                          color: Color(0xFF173F70),
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
    });
  }
}
