import 'package:flutter/material.dart';

class CreateTask extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Task',
          style: TextStyle(
              color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField('Task Name', 'ex. Create an Essay'),
            SizedBox(height: 15),
            _buildTextField('Description', 'ex. Essay about AI'),
            SizedBox(height: 15),
            _buildDropdownField('Priority',
                ['Low Priority', 'Medium Priority', 'High Priority']),
            SizedBox(height: 15),
            _buildDateField(context),
            SizedBox(height: 15),
            _buildTimeField(context),
            SizedBox(height: 15),
            _buildTextField('Duration', 'ex. 30 mins'),
            SizedBox(height: 15),
            _buildDropdownField('Subject', ['Math', 'Science', 'English']),
            Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Create task action
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
                child: Text(
                  'Create Task',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildDropdownField(String label, List<String> items) {
    String? selectedValue;
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: (value) {
        selectedValue = value;
        // Handle selection
      },
      value: selectedValue,
      dropdownColor: Colors.white,
      style: TextStyle(color: Colors.black),
      icon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade700),
    );
  }

  Widget _buildDateField(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        labelText: 'Deadline',
        hintText: '11 January 2024',
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        suffixIcon: Icon(Icons.calendar_today, color: Colors.grey.shade700),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
      readOnly: true,
      onTap: () {
        // Show date picker
      },
    );
  }

  Widget _buildTimeField(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        labelText: 'Time',
        hintText: '11:59 PM',
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
      readOnly: true,
      onTap: () {
        // Show time picker
      },
    );
  }
}
