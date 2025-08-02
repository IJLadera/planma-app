import 'package:flutter/material.dart';
import 'package:planma_app/Providers/goal_provider.dart';
import 'package:planma_app/Providers/semester_provider.dart';
import 'package:planma_app/goals/widget/widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:planma_app/models/goals_model.dart';
import 'package:planma_app/subject/semester/add_semester.dart';
import 'package:provider/provider.dart';

class EditGoal extends StatefulWidget {
  final Goal goal;

  const EditGoal({super.key, required this.goal});

  @override
  _EditGoal createState() => _EditGoal();
}

class _EditGoal extends State<EditGoal> {
  late TextEditingController _goalCodeController;
  late TextEditingController _descriptionController;

  // Dropdown selections
  String? _selectedGoalType;
  int? _selectedSemesterId;
  String? _selectedSemester;
  String? _selectedTimeframe;

  Duration _targetDuration = Duration();

  final List<String> _goalType = ['Academic', 'Personal'];
  final List<String> _timeframe = ['Daily', 'Weekly', 'Monthly'];

  @override
  void initState() {
    super.initState();

    // Pre-fill fields with current task details
    _goalCodeController = TextEditingController(text: widget.goal.goalName);
    _descriptionController =
        TextEditingController(text: widget.goal.goalDescription);

    _selectedTimeframe = widget.goal.timeframe;
    _targetDuration = Duration(hours: widget.goal.targetHours);
    _selectedGoalType = widget.goal.goalType;
    _selectedSemesterId = widget.goal.semester;

    // Fetch semesters when the screen loads
    final semesterProvider =
        Provider.of<SemesterProvider>(context, listen: false);

    semesterProvider.fetchSemesters().then((_) {
      setState(() {
        if (semesterProvider.semesters.isNotEmpty) {
          // Find the semester that matches `selectedSemesterId`
          final matchedSemester = semesterProvider.semesters.firstWhere(
            (semester) => semester['semester_id'] == _selectedSemesterId,
            orElse: () => {},
          );

          if (matchedSemester != null) {
            _selectedSemester =
                "${matchedSemester['acad_year_start']} - ${matchedSemester['acad_year_end']} ${matchedSemester['semester']}";
            print("Pre-selected semester: $_selectedSemester");
          } else {
            // Fallback to the first semester if no match is found
            final defaultSemester = semesterProvider.semesters.first;
            _selectedSemester =
                "${defaultSemester['acad_year_start']} - ${defaultSemester['acad_year_end']} ${defaultSemester['semester']}";
            _selectedSemesterId = defaultSemester['semester_id'];
            print("Default selected semester: $_selectedSemester");
          }
        }
      });
    });
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.openSans(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 100),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.openSans(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF50B6FF),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 100),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _editGoal(BuildContext context) async {
    final provider = Provider.of<GoalProvider>(context, listen: false);

    String goalName = _goalCodeController.text.trim();
    String? rawGoalDescription = _descriptionController.text.trim();
    String? normalizedGoalDescription = rawGoalDescription.isEmpty ? null : rawGoalDescription;

    if (goalName.isEmpty) {
      _showError(context, 'Goal name is required.');
      return;
    }

    if (rawGoalDescription.isEmpty) {
      _showError(context, 'Goal description is required.');
      return;
    }

    if (_selectedGoalType == null) {
      _showError(context, 'Goal type is required.');
      return;
    }

    if (_selectedTimeframe == null) {
      _showError(context, 'Timeframe is required.');
      return;
    }

    if (_selectedGoalType == 'Academic' && _selectedSemesterId == null) {
      _showError(context, 'Semester is required for Academic goals.');
      return;
    }

    try {
      int? semester =
          _selectedGoalType == 'Personal' ? null : _selectedSemesterId;

      print('Starting to update goal...');
      await provider.updateGoal(
          goalId: widget.goal.goalId!,
          goalName: goalName,
          goalDescription: normalizedGoalDescription,
          timeframe: _selectedTimeframe!,
          targetHours: _targetDuration,
          goalType: _selectedGoalType!,
          semester: semester);
      print('Schedule updated successfully!');

      _showSuccess(context, 'Goal updated successfully!');
      Navigator.pop(context, true);
    } catch (error) {
      String errorMessage;

      if (error.toString().contains('Duplicate goal entry detected')) {
        errorMessage = 'This goal already exists.';
      } else {
        errorMessage = 'Failed to update goal: $error';
      }
      _showError(context, errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Goal',
          style: GoogleFonts.openSans(
            color: Color(0xFF173F70),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Color(0xFFFFFFFF),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Consumer<SemesterProvider>(
          builder: (context, semesterProvider, child) {
            // Prepare the dropdown list of semesters
            List<Map<String, dynamic>> semesters = semesterProvider.semesters;
            List<String> semesterItems = semesters
                .map((semester) =>
                    "${semester['acad_year_start']} - ${semester['acad_year_end']} ${semester['semester']}")
                .toList();
            semesterItems.add('- Add Semester -');
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        CustomWidgets.buildTitle(
                          'Goal Name',
                        ),
                        const SizedBox(height: 12),
                        CustomWidgets.buildTextField(
                          _goalCodeController,
                          'Goal Name',
                        ),
                        const SizedBox(height: 12),
                        CustomWidgets.buildTitle(
                          'Description',
                        ),
                        const SizedBox(height: 12),
                        CustomWidgets.buildTextField(
                          _descriptionController,
                          'Description',
                        ),
                        const SizedBox(height: 12),
                        CustomWidgets.buildTitle('Timeframe'),
                        const SizedBox(height: 12),
                        CustomWidgets.buildDropdownField(
                          label: 'Timeframe',
                          textStyle: GoogleFonts.openSans(fontSize: 16),
                          value: _selectedTimeframe,
                          items: _timeframe,
                          onChanged: (value) =>
                              setState(() => _selectedTimeframe = value),
                        ),
                        const SizedBox(height: 12),
                        CustomWidgets.buildTitle('Target Duration'),
                        const SizedBox(height: 12),
                        CustomWidgets.buildScheduleDatePicker(
                          context: context,
                          displayText: CustomWidgets.formatDurationText(
                              _targetDuration), // Correct call
                          onPickerTap: () async {
                            // Pass the required arguments: context, initialDuration, and the callback function
                            await CustomWidgets.showDurationPicker(
                                context, _targetDuration, (newDuration) {
                              setState(() {
                                _targetDuration =
                                    newDuration; // Update target duration
                              });
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        CustomWidgets.buildTitle(
                          'Goal Type',
                        ),
                        const SizedBox(height: 12),
                        CustomWidgets.buildDropdownField(
                          label: 'Goal Type',
                          textStyle: GoogleFonts.openSans(fontSize: 16),
                          value: _selectedGoalType,
                          items: _goalType,
                          onChanged: (String? value) {
                            setState(() {
                              _selectedGoalType = value;

                              // Reset semester fields if goal type is changed
                              if (_selectedGoalType == 'Personal') {
                                _selectedSemester = null;
                                _selectedSemesterId = null;
                              } else if (_selectedGoalType == 'Academic' &&
                                  _selectedSemesterId == null) {
                                // Ensure a valid semester is selected when changing to 'Academic'
                                final semesterProvider =
                                    Provider.of<SemesterProvider>(context,
                                        listen: false);
                                if (semesterProvider.semesters.isNotEmpty) {
                                  final defaultSemester =
                                      semesterProvider.semesters.first;
                                  _selectedSemester =
                                      "${defaultSemester['acad_year_start']} - ${defaultSemester['acad_year_end']} ${defaultSemester['semester']}";
                                  _selectedSemesterId =
                                      defaultSemester['semester_id'];
                                }
                              }
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        if (_selectedGoalType == 'Academic') ...[
                          CustomWidgets.buildDropdownField(
                            label: 'Select Semester',
                            textStyle: GoogleFonts.openSans(fontSize: 14),
                            value: _selectedSemester,
                            items: semesterItems,
                            onChanged: (value) {
                              setState(() {
                                if (value == '- Add Semester -') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            AddSemesterScreen()),
                                  ).then(
                                      (_) => semesterProvider.fetchSemesters());
                                } else {
                                  _selectedSemester = value;

                                  // Extract semester details for selection
                                  List<String> semesterParts =
                                      _selectedSemester!.split(' ');
                                  int acadYearStart =
                                      int.parse(semesterParts[0]);
                                  int acadYearEnd = int.parse(semesterParts[2]);
                                  String semesterType =
                                      "${semesterParts[3]} ${semesterParts[4]}";

                                  final selectedSemesterMap =
                                      semesterProvider.semesters.firstWhere(
                                    (semester) =>
                                        semester['acad_year_start'] ==
                                            acadYearStart &&
                                        semester['acad_year_end'] ==
                                            acadYearEnd &&
                                        semester['semester'] == semesterType,
                                    orElse: () => {},
                                  );
                                  _selectedSemesterId =
                                      selectedSemesterMap['semester_id'];
                                }
                              });
                            },
                            backgroundColor: const Color(0xFFF5F5F5),
                            labelColor: Colors.black,
                            textColor: Colors.black,
                            borderRadius: 30.0,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                            fontSize: 14.0,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 20.0),
                  child: ElevatedButton(
                    onPressed: () => _editGoal(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF173F70),
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 100),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      'Edit Goal',
                      style: GoogleFonts.openSans(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      resizeToAvoidBottomInset: false,
    );
  }

  @override
  void dispose() {
    _goalCodeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
