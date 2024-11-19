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

  static Widget buildDropdownField(
    String label,
    String? value,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 138, 172, 207),
        borderRadius: BorderRadius.circular(30),
      ),
      child: SizedBox(
        width: 400,
        child: DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
              color: Colors.black,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.all(16),
          ),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
            );
          }).toList(),
          onChanged: (value) => onChanged(value),
        ),
      ),
    );
  }

  // Adjusted to accept dynamic Map
  static Widget buildSessionTile(Map<String, dynamic> session) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            session['name'] ?? 'Session Name',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Date: ${session['date'] ?? 'Not Set'}',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          Text(
            'Time Period: ${session['timePeriod'] ?? 'Not Set'}',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // Helper for a detail tile
  static Widget buildDetailTile(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
