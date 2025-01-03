import 'package:flutter/material.dart';
import 'package:planma_app/Providers/goal_provider.dart';
import 'package:planma_app/Providers/semester_provider.dart';
import 'package:planma_app/goals/edit_goal.dart';
import 'package:planma_app/goals/edit_goal_session.dart';
import 'package:planma_app/goals/widget/goal_detail_row.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:planma_app/models/goals_model.dart';
import 'package:provider/provider.dart';

class GoalDetailScreen extends StatefulWidget {
  final Goal goal;

  const GoalDetailScreen({super.key, required this.goal});

  @override
  State<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends State<GoalDetailScreen> {
  List<Map<String, dynamic>>? sessions = [];
  String semesterDetails = 'Loading...';
  late SemesterProvider semesterProvider;
  late GoalProvider goalProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchSemesterDetails();
    });
  }

  Future<void> _fetchSemesterDetails() async {
    final semesterProvider =
        Provider.of<SemesterProvider>(context, listen: false);
    print('Fetching semester with ID: ${widget.goal.semester}');
    try {
      final semester =
          await semesterProvider.getSemesterDetails(widget.goal.semester!);
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
    return Consumer<GoalProvider>(builder: (context, goalProvider, child) {
      final goal = goalProvider.goals
          .firstWhere((goal) => goal.goalId == widget.goal.goalId);

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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EditGoal(goal: widget.goal)),
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
                  GoalDetailRow(
                      label: 'Description:', detail: goal.goalDescription),
                  const Divider(),
                  GoalDetailRow(label: 'Timeframe:', detail: goal.timeframe),
                  const Divider(),
                  GoalDetailRow(
                      label: 'Target Hours:',
                      detail: goal.targetHours.toString()),
                  const Divider(),
                  GoalDetailRow(label: 'Type:', detail: goal.goalType),
                  const Divider(),
                  GoalDetailRow(label: 'Semester:', detail: semesterDetails),
                  const Divider(),
                  const SizedBox(height: 8),

                  sessions!.isNotEmpty
                      ? ListView.builder(
                          shrinkWrap: true,
                          itemCount: sessions!.length,
                          itemBuilder: (context, index) {
                            final session = sessions![index];
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(
                                      0xFFE0E0E0), // Background color (light gray)
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  children: [
                                    // Play Icon
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: const Color(
                                            0xFF173F70), // Icon background color
                                      ),
                                      padding: const EdgeInsets.all(8.0),
                                      child: const Icon(
                                        Icons.play_arrow,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // Vertical Divider
                                    Container(
                                      width: 1.5,
                                      height: 30,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 12),
                                    // Session Details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            session['sessionName'],
                                            style: GoogleFonts.openSans(
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFF173F70),
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Text(
                                                session['date'] ?? 'Date',
                                                style: GoogleFonts.openSans(
                                                  color:
                                                      const Color(0xFF173F70),
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const Spacer(),
                                              Text(
                                                session['timePeriod'] ??
                                                    '(Time Period)',
                                                style: GoogleFonts.openSans(
                                                  color:
                                                      const Color(0xFF173F70),
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        )
                      : Center(
                          child: Text(
                            'No sessions added yet.',
                            style: GoogleFonts.openSans(
                                color: const Color(0xFF173F70)),
                          ),
                        ),
                  SizedBox(height: 12),
                  // Add Session Button
                  Align(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditGoalSession(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFB8B8B8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 24),
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
