import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomWidgets {
  // Method to build a TextField with custom style
  static Widget buildTextField(
      TextEditingController controller, String labelText) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 138, 172, 207),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
      ),
    );
  }

  // Method to build a DateTile (with tap to select date)
  static Widget buildDateTile(String label, DateTime? date,
      BuildContext context, bool isScheduledDate, Function selectDate) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 138, 172, 207),
        borderRadius: BorderRadius.circular(30),
      ),
      child: ListTile(
        title: Text(
            '$label: ${date != null ? DateFormat('dd MMMM yyyy').format(date) : 'Select Date'}'),
        trailing: Icon(Icons.calendar_today),
        onTap: () => selectDate(context, isScheduledDate),
      ),
    );
  }

  // Method to build a time field with gesture and custom design
  static Widget buildTimeField(String label, TimeOfDay? time,
      BuildContext context, bool isStartTime, Function selectTime) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 138, 172, 207),
        borderRadius: BorderRadius.circular(30),
      ),
      child: GestureDetector(
        onTap: () => selectTime(context, isStartTime),
        child: AbsorbPointer(
          child: TextFormField(
            decoration: InputDecoration(
              labelText: label,
              suffixIcon: Icon(Icons.access_time),
              hintText: time != null ? time.format(context) : 'Select Time',
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
          ),
        ),
      ),
    );
  }
}

