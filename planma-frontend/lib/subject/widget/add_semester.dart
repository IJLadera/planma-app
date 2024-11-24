import 'package:flutter/material.dart';
import 'package:planma_app/Providers/semester_provider.dart';
import 'package:planma_app/subject/widget/widget.dart';
import 'package:provider/provider.dart';

class AddSemesterScreen extends StatefulWidget {
  @override
  _AddSemesterScreenState createState() => _AddSemesterScreenState();
}

class _AddSemesterScreenState extends State<AddSemesterScreen> {
  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();

  DateTime? startDate;
  DateTime? endDate;
  String? _selectedSemester;
  String? _selectedYearLevel;
  String? _selectedStartYear;
  String? _selectedEndYear;
  final List<String> _semesterOptions = ['1st Semester', '2nd Semester'];
  final List<String> _yearLevelOptions = ['1st Year', '2nd Year', '3rd Year', '4th Year', '5th Year'];

  // Function to show the year picker in a dialog
  void _showYearPicker(BuildContext context, bool isStartYear) {
    final startYear = 2024; // Start year
    final years = List<int>.generate(
        100, (index) => startYear + index); // Generate years from 2024 onward

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
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          startDate = picked;
          startDateController.text = "${startDate!.year}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.day.toString().padLeft(2, '0')}";
        } else {
          endDate = picked;
          endDateController.text = "${endDate!.year}-${endDate!.month.toString().padLeft(2, '0')}-${endDate!.day.toString().padLeft(2, '0')}";
        }
      });
    }
  }

  void _submitSemester(BuildContext context) async {
    final provider = Provider.of<SemesterProvider>(context, listen: false);

    // Null checks for critical fields
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Semester'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
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
            Text(
              'Academic Year',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showYearPicker(context, true),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Text(
                            _selectedStartYear != null
                                ? '$_selectedStartYear'
                                : 'Start Year',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const Spacer(),
                          const Icon(Icons.calendar_today),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showYearPicker(context, false),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Text(
                            _selectedEndYear != null
                                ? '$_selectedEndYear'
                                : 'End Year',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const Spacer(),
                          const Icon(Icons.calendar_today),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Year Level',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            CustomWidgets.buildDropdownField(
              label: 'Choose Year Level',
              value: _selectedYearLevel,
              items: _yearLevelOptions, 
              onChanged: (String? value) {
                setState(() {
                  _selectedYearLevel = value; 
                });
              },
              backgroundColor: const Color(0xFFF5F5F5),
              labelColor: Colors.black,
              textColor: Colors.black,
              borderRadius: 30.0,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              fontSize: 14.0,
            ),
            const SizedBox(height: 16),
            Text(
              'Semester',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            CustomWidgets.buildDropdownField(
              label: 'Choose Semester',
              value: _selectedSemester,
              items: _semesterOptions, 
              onChanged: (String? value) {
                setState(() {
                  _selectedSemester = value;
                });
              },
              backgroundColor: const Color(0xFFF5F5F5),
              labelColor: Colors.black,
              textColor: Colors.black,
              borderRadius: 30.0,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              fontSize: 14.0,
            ),
            const SizedBox(height: 16),
            Text(
              'Semester Dates',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: GestureDetector(
                        onTap: () => _selectDate(context, true),
                        child: AbsorbPointer(
                          child: TextFormField(
                            style: const TextStyle(color: Colors.black),
                            decoration: const InputDecoration(
                              hintText: "Start Date",
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                            controller: startDateController,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: GestureDetector(
                        onTap: () => _selectDate(context, false),
                        child: AbsorbPointer(
                          child: TextFormField(
                            style: const TextStyle(color: Colors.black),
                            decoration: const InputDecoration(
                              hintText: "End Date",
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                            controller: endDateController,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
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
                child: const Text(
                  'Add Semester',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
