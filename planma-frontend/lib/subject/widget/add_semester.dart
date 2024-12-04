import 'package:flutter/material.dart';
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
        if (isStartDate) {
          startDate = picked;
          startDateController.text =
              "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
        } else {
          endDate = picked;
          endDateController.text =
              "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
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
      await provider.addSemester(
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
      Navigator.pop(context);
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
        title: const Text(
          'Add Semester',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildTitle('Academic Year'),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildYearPickerButton(context, 'Start Year', true),
                const SizedBox(width: 16),
                _buildYearPickerButton(context, 'End Year', false),
              ],
            ),
            const SizedBox(height: 16),
            _buildTitle('Year Level'),
            _buildDropdown(
                'Choose Year Level', _selectedYearLevel, _yearLevelOptions,
                (value) {
              setState(() => _selectedYearLevel = value);
            }),
            const SizedBox(height: 16),
            _buildTitle('Semester'),
            _buildDropdown(
                'Choose Semester', _selectedSemester, _semesterOptions,
                (value) {
              setState(() => _selectedSemester = value);
            }),
            const SizedBox(height: 16),
            _buildTitle('Semester Dates'),
            const SizedBox(height: 20),
            Row(
              children: [
                _buildDateField('Start Date', startDateController, true),
                const SizedBox(width: 16),
                _buildDateField('End Date', endDateController, false),
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
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildYearPickerButton(
      BuildContext context, String hint, bool isStartYear) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _showYearPicker(context, isStartYear),
        child: _buildContainer(
          Text(
            isStartYear ? _selectedStartYear ?? hint : _selectedEndYear ?? hint,
            style: GoogleFonts.openSans(fontSize: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildDateField(
      String hint, TextEditingController controller, bool isStartDate) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _selectDate(context, isStartDate),
        child: AbsorbPointer(
          child: TextFormField(
            controller: controller,
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(
                hintText: hint, suffixIcon: const Icon(Icons.calendar_today)),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(String hint, String? value, List<String> items,
      ValueChanged<String?> onChanged) {
    return CustomWidgets.buildDropdownField(
      label: hint,
      value: value,
      items: items,
      onChanged: onChanged,
      backgroundColor: const Color(0xFFF5F5F5),
      labelColor: Colors.black,
      textColor: Colors.black,
      borderRadius: 30.0,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      fontSize: 14.0,
    );
  }

  Widget _buildContainer(Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          child,
          const Spacer(),
          const Icon(Icons.calendar_today),
        ],
      ),
    );
  }
}
