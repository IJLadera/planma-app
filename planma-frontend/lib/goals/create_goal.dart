import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:planma_app/Providers/goal_provider.dart';
import 'package:planma_app/Providers/semester_provider.dart';
import 'package:planma_app/goals/widget/widget.dart';
import 'package:planma_app/subject/semester/add_semester.dart';
import 'package:provider/provider.dart';

class AddGoalScreen extends StatefulWidget {
  const AddGoalScreen({super.key});

  @override
  _AddGoalScreenState createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends State<AddGoalScreen> {
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

  void _submitGoal(BuildContext context) async {
    final provider = Provider.of<GoalProvider>(context, listen: false);

    String goalName = _goalNameController.text.trim();
    String goalDescription = _descriptionController.text.trim();

    if (goalName.isEmpty ||
        goalDescription.isEmpty ||
        _selectedGoalType == null ||
        _selectedTimeframe == null ||
        (_selectedGoalType == 'Academic' && _selectedSemesterId == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields!')),
      );
      return;
    }

    try {
      int? semester =
          _selectedGoalType == 'Personal' ? null : _selectedSemesterId;

      await provider.addGoal(
          goalName: goalName,
          goalDescription: goalDescription,
          timeframe: _selectedTimeframe!,
          targetHours: _targetDuration,
          goalType: _selectedGoalType!,
          semester: semester);

      // After validation and adding logic
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            mainAxisSize: MainAxisSize.min, // Make the row compact
            mainAxisAlignment: MainAxisAlignment.center, // Center the content
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Text(
                'Goal Created Successfully!',
                style: GoogleFonts.openSans(fontSize: 16, color: Colors.white),
                overflow: TextOverflow.ellipsis,
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // Make it a square
          ),
          backgroundColor: Color(0xFF50B6FF).withOpacity(0.8),
          elevation: 12, // Add shadow for better visibility
        ),
      );

      Navigator.pop(context);
      // Clear fields after adding
      _clearFields();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error,
                  color: Colors.white, size: 24), // Error icon
              const SizedBox(width: 8),
              Expanded(
                // Prevents text overflow
                child: Text(
                  'Failed To Create Goal (1): $error',
                  style:
                      GoogleFonts.openSans(color: Colors.white, fontSize: 16),
                  overflow: TextOverflow.ellipsis, // Handles long errors
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height * 0.4, // Moves to center
            left: 30,
            right: 30,
            top: 100,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // Square shape
          ),
          backgroundColor: Colors.red, // Error background color
          elevation: 10, // Adds shadow
        ),
      );
    }
  }

  // Clear fields after submit
  void _clearFields() {
    _goalNameController.clear();
    _descriptionController.clear();
    _timeframe.clear();
    _selectedGoalType = null;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    // Fetch semesters when the screen loads
    final semesterProvider =
        Provider.of<SemesterProvider>(context, listen: false);
    semesterProvider.fetchSemesters().then((_) {
      setState(() {
        // Set default value if there are semesters available
        if (semesterProvider.semesters.isNotEmpty) {
          // Select the first semester
          selectedSemester =
              "${semesterProvider.semesters[0]['acad_year_start']} - ${semesterProvider.semesters[0]['acad_year_end']} ${semesterProvider.semesters[0]['semester']}";

          final defaultSemester = semesterProvider.semesters.first;
          _selectedSemesterId = defaultSemester['semester_id'];

          // Log the selected semester
          print("Default selected semester: $selectedSemester");
          print("Default selected semester ID: $_selectedSemesterId");
        }
      });
    });
  }

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
