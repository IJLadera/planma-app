import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:planma_app/Providers/semester_provider.dart';
import 'package:planma_app/subject/widget/widget.dart'; // Assuming this contains CustomWidgets.
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class EditSemesterScreen extends StatefulWidget {
  final Map<String, dynamic> semester;

  const EditSemesterScreen({super.key, required this.semester});

  @override
  _EditSemesterScreenState createState() => _EditSemesterScreenState();
}

class _EditSemesterScreenState extends State<EditSemesterScreen> {
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();

  DateTime? startDate;
  DateTime? endDate;
  String? _selectedSemester;
  String? _selectedYearLevel;
  String? _selectedStartYear;
  String? _selectedEndYear;

  final List<String> _semesterOptions = ['1st Semester', '2nd Semester'];
  final List<String> _yearLevelOptions = [
    '1st Year',
    '2nd Year',
    '3rd Year',
    '4th Year',
    '5th Year'
  ];

  void _showYearPicker(BuildContext context, bool isStartYear) {
    final startYear = 2024;
    final years = List.generate(100, (index) => startYear + index);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Select Year',
            style: GoogleFonts.openSans(fontSize: 14),
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
      initialDate:
          initial ?? DateTime.now(), // Show previously selected or today
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

  @override
  void initState() {
    super.initState();

    // Initialize values from the provided semester data
    _selectedStartYear = widget.semester['acad_year_start']?.toString();
    _selectedEndYear = widget.semester['acad_year_end']?.toString();
    _selectedYearLevel = widget.semester['year_level'];
    _selectedSemester = widget.semester['semester'];

    // Parse and format the start and end dates
    if (widget.semester['sem_start_date'] != null) {
      startDate = DateTime.parse(widget.semester['sem_start_date']);
      startDateController.text = DateFormat('dd MMMM yyyy').format(startDate!);
    }

    if (widget.semester['sem_end_date'] != null) {
      endDate = DateTime.parse(widget.semester['sem_end_date']);
      endDateController.text = DateFormat('dd MMMM yyyy').format(endDate!);
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

    // Validate individual fields with clear messages
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
      await provider.editSemester(
        semesterId: widget.semester['semester_id'],
        acadYearStart: int.parse(_selectedStartYear!),
        acadYearEnd: int.parse(_selectedEndYear!),
        yearLevel: _selectedYearLevel!,
        semester: _selectedSemester!,
        selectedStartDate: startDate!,
        selectedEndDate: endDate!,
      );

      // Success Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 10),
              Text(
                'Semester updated successfully!',
                style: GoogleFonts.openSans(color: Colors.white),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 100),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          duration: const Duration(seconds: 3),
        ),
      );

      Navigator.pop(context);
    } catch (error) {
      String errorMessage;

      if (error.toString().contains('Duplicate semester')) {
        errorMessage = 'This semester already exists.';
      } else {
        errorMessage = 'Failed to update semester: ${error.toString()}';
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
      appBar: AppBar(
        title: Text(
          'Edit Semester',
          style: GoogleFonts.openSans(
            fontSize: 20,
            color: Color(0xFF173F70),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildTitle('Academic Year'),
              const SizedBox(height: 16),
              Row(
                children: [
                  // Start Year Button
                  CustomWidgets.buildYearPickerButton(
                    context: context,
                    hint: "Start Year", // Hint for start year
                    isStartYear: true, // Set to true for start year
                    selectedStartYear:
                        _selectedStartYear, // Selected start year (can be null if not selected)
                    selectedEndYear:
                        null, // Don't pass the end year here, it's only for start year
                    onTap: (BuildContext context, bool isStartYear) {
                      // Trigger the year picker for the start year
                      _showYearPicker(context, isStartYear);
                    },
                  ),
                  const SizedBox(width: 12),
                  // End Year Button
                  CustomWidgets.buildYearPickerButton(
                    context: context,
                    hint: "End Year", // Hint for end year
                    isStartYear: false, // Set to false for end year
                    selectedStartYear: null, // Don't pass the start year here
                    selectedEndYear:
                        _selectedEndYear, // Selected end year (can be null if not selected)
                    onTap: (BuildContext context, bool isStartYear) {
                      // Trigger the year picker for the end year
                      _showYearPicker(context, isStartYear);
                    },
                  )
                ],
              ),
              const SizedBox(height: 12),
              _buildTitle('Year Level'),
              const SizedBox(height: 12),
              CustomWidgets.buildDropdownField(
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
              CustomWidgets.buildDropdownField(
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
                  CustomWidgets.buildDateTile(
                    'Start Date',
                    startDateController,
                    context,
                    true, // Pass true for start date
                    (BuildContext context, TextEditingController controller) {
                      _selectDate(context, true); // Pass true for start date
                    },
                  ),
                  SizedBox(width: 10),
                  CustomWidgets.buildDateTile(
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
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 20.0),
                child: ElevatedButton(
                  onPressed: () => _submitSemester(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF173F70),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 100),
                  ),
                  child: Text(
                    'Edit Semester',
                    style:
                        GoogleFonts.openSans(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
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
          fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF173F70)),
    );
  }
}
