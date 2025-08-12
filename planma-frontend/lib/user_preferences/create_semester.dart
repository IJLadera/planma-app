import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:planma_app/Providers/semester_provider.dart';
import 'package:planma_app/user_preferences/set_goal.dart';
import 'package:planma_app/user_preferences/widget/create_goal.dart';
import 'package:planma_app/user_preferences/widget/widget.dart';
import 'package:provider/provider.dart';

class PlanSemesterPage extends StatefulWidget {
  const PlanSemesterPage({super.key});

  @override
  State<PlanSemesterPage> createState() => _PlanSemesterPageState();
}

class _PlanSemesterPageState extends State<PlanSemesterPage> {
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();

  String? _selectedSemester;
  String? _selectedYearLevel;
  String? _selectedStartYear;
  String? _selectedEndYear;
  DateTime? startDate;
  DateTime? endDate;

  final List<String> _semesterOptions = ['1st Semester', '2nd Semester'];
  final List<String> _yearLevelOptions = [
    '1st Year',
    '2nd Year',
    '3rd Year',
    '4th Year',
    '5th Year'
  ];

  void _showYearPicker(BuildContext context, bool isStartYear) {
    final startYear = 2025;
    final years = List.generate(100, (index) => startYear + index);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Select Year',
            style: GoogleFonts.openSans(
                fontSize: 18, color: const Color(0xFF173F70)),
          ),
          content: SizedBox(
            height: 300,
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: years.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(years[index].toString()),
                  onTap: () {
                    setState(() {
                      if (isStartYear) {
                        _selectedStartYear = years[index].toString();
                      } else {
                        _selectedEndYear = years[index].toString();
                      }
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final initial = isStartDate ? startDate : endDate;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        final formattedDate = DateFormat('dd MMMM yyyy').format(picked);

        if (isStartDate) {
          startDate = picked;
          startDateController.text = formattedDate;
        } else {
          endDate = picked;
          endDateController.text = formattedDate;
        }
      });
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.openSans(color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 100),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _submitSemester(BuildContext context) async {
    final provider = Provider.of<SemesterProvider>(context, listen: false);

    // Validate input fields individually with meaningful error messages
    if (_selectedStartYear == null) {
      _showError(context, "Please select the start academic year.");
      return;
    }
    if (_selectedEndYear == null) {
      _showError(context, "Please select the end academic year.");
      return;
    }
    if (_selectedYearLevel == null) {
      _showError(context, "Please select the year level.");
      return;
    }
    if (_selectedSemester == null) {
      _showError(context, "Please select the semester.");
      return;
    }
    if (startDate == null) {
      _showError(context, "Please choose a semester start date.");
      return;
    }
    if (endDate == null) {
      _showError(context, "Please choose a semester end date.");
      return;
    }

    try {
      await provider.addSemester(
        acadYearStart: int.parse(_selectedStartYear!),
        acadYearEnd: int.parse(_selectedEndYear!),
        yearLevel: _selectedYearLevel!,
        semester: _selectedSemester!,
        selectedStartDate: startDate!,
        selectedEndDate: endDate!,
      );

      // Success Snackbar
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Row(
      //       children: [
      //         const Icon(Icons.check_circle, color: Colors.white),
      //         const SizedBox(width: 10),
      //         Center(
      //           child: Text(
      //             'Semester added successfully!',
      //             style: GoogleFonts.openSans(color: Colors.white),
      //           ),
      //         ),
      //       ],
      //     ),
      //     backgroundColor: Colors.green,
      //     behavior: SnackBarBehavior.floating,
      //     margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 100),
      //     shape:
      //         RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      //     duration: const Duration(seconds: 3),
      //   ),
      // );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GoalSelectionPage(),
        ),
      );
    } catch (error) {
      String errorMessage;

      if (error.toString().contains('Duplicate semester')) {
        errorMessage = 'This semester already exists.';
      } else {
        errorMessage = 'Failed to add semester: ${error.toString()}';
      }

      _showError(context, errorMessage);
    }
  }

  @override
  void dispose() {
    startDateController.dispose();
    endDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              // Title
              Center(
                child: Text(
                  "Let’s plan your semester!",
                  style: GoogleFonts.openSans(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF173F70),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle
              Center(
                child: Text(
                  "When does your current semester start and end?",
                  style:
                      GoogleFonts.openSans(fontSize: 16, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 32),

              // Academic Year Section
              _buildTitle("Academic Year"),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: CustomWidget.buildYearPickerButton(
                      context: context,
                      hint: "Start Year",
                      isStartYear: true,
                      selectedStartYear: _selectedStartYear,
                      selectedEndYear: null,
                      onTap: (BuildContext context, bool isStartYear) {
                        // Trigger the year picker for the start year
                        _showYearPicker(context, isStartYear);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomWidget.buildYearPickerButton(
                      context: context,
                      hint: "End Year",
                      isStartYear: false,
                      selectedStartYear: null,
                      selectedEndYear: _selectedEndYear,
                      onTap: (BuildContext context, bool isStartYear) {
                        // Trigger the year picker for the start year
                        _showYearPicker(context, isStartYear);
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Year Level Section
              _buildTitle('Year Level'),
              const SizedBox(height: 12),
              CustomWidget.buildDropdownField(
                label: 'Choose Year Level',
                value: _selectedYearLevel,
                items: _yearLevelOptions,
                onChanged: (value) {
                  setState(() => _selectedYearLevel = value);
                },
                backgroundColor: const Color(0xFFF5F5F5),
                labelColor: Colors.black,
                textColor: Colors.black,
                borderRadius: 30.0,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                fontSize: 14.0,
              ),
              const SizedBox(height: 12),
              _buildTitle('Semester'),
              const SizedBox(height: 12),
              CustomWidget.buildDropdownField(
                label: 'Choose Semester',
                value: _selectedSemester,
                items: _semesterOptions,
                onChanged: (value) {
                  setState(() => _selectedSemester = value);
                },
                backgroundColor: const Color(0xFFF5F5F5),
                labelColor: Colors.black,
                textColor: Colors.black,
                borderRadius: 30.0,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                fontSize: 14.0,
              ),
              const SizedBox(height: 12),
              _buildTitle('Semester Dates'),
              const SizedBox(height: 12),
              Row(
                children: [
                  CustomWidget.buildDateTile(
                    'Start Date',
                    startDateController,
                    context,
                    true, // Pass true for start date
                    (BuildContext context, TextEditingController controller) {
                      _selectDate(context, true); // Pass true for start date
                    },
                  ),
                  SizedBox(width: 10),
                  CustomWidget.buildDateTile(
                    'End Date',
                    endDateController,
                    context,
                    false, // Pass false for end date
                    (BuildContext context, TextEditingController controller) {
                      _selectDate(context, false); // Pass false for end date
                    },
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 20.0),
                child: ElevatedButton(
                  onPressed: () {
                    _submitSemester(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF173F70),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 100),
                  ),
                  child: Text(
                    'Next',
                    style:
                        GoogleFonts.openSans(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: RichText(
                  text: TextSpan(
                    text: 'Skip for now',
                    style: GoogleFonts.openSans(
                      color: const Color(0xFF173F70),
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GoalSelectionPage(),
                          ),
                        );
                      },
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.openSans(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF173F70),
      ),
    );
  }
}
