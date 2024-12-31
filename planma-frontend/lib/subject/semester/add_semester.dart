import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:planma_app/Providers/semester_provider.dart';
import 'package:planma_app/subject/widget/widget.dart'; // Assuming this contains CustomWidgets.
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class AddSemesterScreen extends StatefulWidget {
  const AddSemesterScreen({super.key});

  @override
  _AddSemesterScreenState createState() => _AddSemesterScreenState();
}

class _AddSemesterScreenState extends State<AddSemesterScreen> {
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
          title: const Text('Select Year'),
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
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        final formattedDate = DateFormat('dd MMMM yyyy')
            .format(picked); // Format date as '07 December 2024'

        if (isStartDate) {
          startDate = picked;
          startDateController.text = formattedDate; // Set formatted start date
        } else {
          endDate = picked;
          endDateController.text = formattedDate; // Set formatted end date
        }
      });
    }
  }

  void _submitSemester(BuildContext context) async {
    final provider = Provider.of<SemesterProvider>(context, listen: false);

    if (_selectedStartYear == null ||
        _selectedEndYear == null ||
        _selectedYearLevel == null ||
        _selectedSemester == null ||
        startDate == null ||
        endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields!')),
      );
      return;
    }

    try {
      final newSemesterId = await provider.addSemester(
        acadYearStart: int.parse(_selectedStartYear!),
        acadYearEnd: int.parse(_selectedEndYear!),
        yearLevel: _selectedYearLevel!,
        semester: _selectedSemester!,
        selectedStartDate: startDate!,
        selectedEndDate: endDate!,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semester added successfully!')),
      );
      Navigator.pop(context, newSemesterId);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add semester: $error')),
      );
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
          'Add Semester',
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _submitSemester(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF173F70),
                  padding: const EdgeInsets.symmetric(vertical: 20),
                ),
                child: const Text('Add Semester',
                    style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
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
