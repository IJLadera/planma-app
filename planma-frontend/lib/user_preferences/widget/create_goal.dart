import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:planma_app/Providers/goal_provider.dart';
import 'package:planma_app/Providers/semester_provider.dart';
import 'package:planma_app/goals/widget/widget.dart';
import 'package:planma_app/subject/semester/add_semester.dart';
import 'package:provider/provider.dart';

class CreateGoal extends StatefulWidget {
  const CreateGoal({super.key});

  @override
  _CreateGoal createState() => _CreateGoal();
}

class _CreateGoal extends State<CreateGoal> {
  // Controllers for input fields
  final _goalNameController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Dropdown selections
  String? _selectedGoalType;
  int? _selectedSemesterId;
  String? selectedSemester;
  String? _selectedTimeframe;
  // Duration variables
  Duration _targetDuration = Duration();

  // Dropdown options
  final List<String> _goalTypes = ['Academic', 'Personal'];
  final List<String> _timeframe = ['Daily', 'Weekly', 'Monthly'];

  // void _showError(BuildContext context, String message) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Row(
  //         children: [
  //           const Icon(Icons.error, color: Colors.white),
  //           const SizedBox(width: 10),
  //           Expanded(
  //             child: Text(
  //               message,
  //               style: GoogleFonts.openSans(color: Colors.white),
  //             ),
  //           ),
  //         ],
  //       ),
  //       backgroundColor: Colors.red,
  //       behavior: SnackBarBehavior.floating,
  //       margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 100),
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  //       duration: const Duration(seconds: 4),
  //     ),
  //   );
  // }

  // void _showSuccess(BuildContext context, String message) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Row(
  //         children: [
  //           const Icon(Icons.check_circle, color: Colors.white),
  //           const SizedBox(width: 10),
  //           Expanded(
  //             child: Text(
  //               message,
  //               style: GoogleFonts.openSans(color: Colors.white),
  //             ),
  //           ),
  //         ],
  //       ),
  //       backgroundColor: Colors.green,
  //       behavior: SnackBarBehavior.floating,
  //       margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 100),
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  //       duration: const Duration(seconds: 3),
  //     ),
  //   );
  // }

  void _submitGoal(BuildContext context) async {
    // final provider = Provider.of<GoalProvider>(context, listen: false);

    // String goalName = _goalNameController.text.trim();
    // String? rawGoalDescription = _descriptionController.text.trim();
    // String? normalizedGoalDescription = rawGoalDescription.isEmpty ? null : rawGoalDescription;

    // if (goalName.isEmpty) {
    //   _showError(context, 'Goal name is required.');
    //   return;
    // }
    // if (rawGoalDescription.isEmpty) {
    //   _showError(context, 'Goal description is required.');
    //   return;
    // }
    // if (_selectedGoalType == null) {
    //   _showError(context, 'Please select a goal type.');
    //   return;
    // }
    // if (_selectedTimeframe == null) {
    //   _showError(context, 'Please select a timeframe.');
    //   return;
    // }
    // if (_selectedGoalType == 'Academic' && _selectedSemesterId == null) {
    //   _showError(context, 'Please select a semester for academic goals.');
    //   return;
    // }

    // try {
    //   int? semester =
    //       _selectedGoalType == 'Personal' ? null : _selectedSemesterId;

    //   await provider.addGoal(
    //       goalName: goalName,
    //       goalDescription: normalizedGoalDescription,
    //       timeframe: _selectedTimeframe!,
    //       targetHours: _targetDuration,
    //       goalType: _selectedGoalType!,
    //       semester: semester);
    //   _showSuccess(context, 'Goal Created Successfully!');

    //   Navigator.pop(context);
    //   // Clear fields after adding
    //   _clearFields();
    // } catch (error) {
    //   _showError(context, 'Failed to create goal: $error');
    // }
  }

  // // Clear fields after submit
  // void _clearFields() {
  //   _goalNameController.clear();
  //   _descriptionController.clear();
  //   _timeframe.clear();
  //   _selectedGoalType = null;
  //   setState(() {});
  // }

  // @override
  // void initState() {
  //   super.initState();
  //   // Fetch semesters when the screen loads
  //   final semesterProvider =
  //       Provider.of<SemesterProvider>(context, listen: false);
  //   semesterProvider.fetchSemesters().then((_) {
  //     setState(() {
  //       // Set default value if there are semesters available
  //       if (semesterProvider.semesters.isNotEmpty) {
  //         // Select the first semester
  //         selectedSemester =
  //             "${semesterProvider.semesters[0]['acad_year_start']} - ${semesterProvider.semesters[0]['acad_year_end']} ${semesterProvider.semesters[0]['semester']}";

  //         final defaultSemester = semesterProvider.semesters.first;
  //         _selectedSemesterId = defaultSemester['semester_id'];

  //         // Log the selected semester
  //         print("Default selected semester: $selectedSemester");
  //         print("Default selected semester ID: $_selectedSemesterId");
  //       }
  //     });
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Goal',
          style: GoogleFonts.openSans(
            color: const Color(0xFF173F70),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.white,
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
                        CustomWidgets.buildTitle('Goal Name'),
                        const SizedBox(height: 12),
                        CustomWidgets.buildTextField(
                            _goalNameController, 'Goal Name'),
                        const SizedBox(height: 12),
                        CustomWidgets.buildTitle('Description'),
                        const SizedBox(height: 12),
                        CustomWidgets.buildTextField(
                            _descriptionController, 'Description'),
                        const SizedBox(height: 12),
                        CustomWidgets.buildTitle('Timeframe'),
                        const SizedBox(height: 12),
                        CustomWidgets.buildDropdownField(
                          label: 'Timeframe',
                          textStyle: GoogleFonts.openSans(fontSize: 14),
                          value: _selectedTimeframe,
                          items: _timeframe,
                          onChanged: (value) =>
                              setState(() => _selectedTimeframe = value),
                        ),
                        const SizedBox(height: 12),
                        CustomWidgets.buildTitle('Target Hours'),
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
                        CustomWidgets.buildTitle('Goal Type'),
                        const SizedBox(height: 12),
                        CustomWidgets.buildDropdownField(
                          label: 'Choose Goal Type',
                          textStyle: GoogleFonts.openSans(fontSize: 14),
                          value: _selectedGoalType,
                          items: _goalTypes,
                          onChanged: (value) =>
                              setState(() => _selectedGoalType = value),
                        ),
                        const SizedBox(height: 12),
                        if (_selectedGoalType == 'Academic') ...[
                          CustomWidgets.buildDropdownField(
                            label: 'Select Semester',
                            textStyle: GoogleFonts.openSans(
                              fontSize: 14,
                            ),
                            value: selectedSemester,
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
                                  selectedSemester = value;

                                  // Split data from value for firstWhere comparison
                                  List<String> semesterParts =
                                      selectedSemester!.split(' ');
                                  int acadYearStart =
                                      int.parse(semesterParts[0]);
                                  int acadYearEnd = int.parse(semesterParts[2]);
                                  String semesterType =
                                      "${semesterParts[3]} ${semesterParts[4]}";

                                  final selectedSemesterMap =
                                      semesterProvider.semesters.firstWhere(
                                    (semester) {
                                      return semester['acad_year_start'] ==
                                              acadYearStart &&
                                          semester['acad_year_end'] ==
                                              acadYearEnd &&
                                          semester['semester'] == semesterType;
                                    },
                                    orElse: () =>
                                        {}, // Return null if no match is found
                                  );
                                  _selectedSemesterId =
                                      selectedSemesterMap['semester_id'];
                                  print(
                                      "Found semester ID: ${selectedSemesterMap['semester_id']}");
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
                    onPressed: () => _submitGoal(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF173F70),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 100),
                    ),
                    child: Text('Add Goal',
                        style: GoogleFonts.openSans(
                          fontSize: 16,
                          color: Colors.white,
                        )),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      "Skip for now",
                      style: GoogleFonts.openSans(
                        fontSize: 14,
                        color: Color(0xFF173F70),
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
    _goalNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
