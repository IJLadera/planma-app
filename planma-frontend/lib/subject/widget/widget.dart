import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DayButton extends StatelessWidget {
  final String day;
  final bool isSelected;
  final VoidCallback onTap;

  const DayButton({
    Key? key,
    required this.day,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 16,
        backgroundColor: isSelected ? Colors.blue : Colors.grey[200],
        child: Text(
          day,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}

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
          contentPadding: const EdgeInsets.all(16),
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
        trailing: const Icon(Icons.calendar_today),
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
              suffixIcon: const Icon(Icons.access_time),
              hintText: time != null ? time.format(context) : 'Select Time',
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ),
    );
  }

  // Method to build a dropdown field with custom design
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
            labelStyle: const TextStyle(
              color: Colors.black,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.all(16),
          ),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: const TextStyle(fontSize: 14, color: Colors.black),
              ),
            );
          }).toList(),
          onChanged: (value) => onChanged(value),
        ),
      ),
    );
  }
}
