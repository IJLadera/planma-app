import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class CustomWidgets {
  // Method to build a TextField with custom style
  static Widget buildTextField(
      TextEditingController controller, String labelText) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0), // Adds padding inside the TextField
        ),
      ),
    );
  }

  // Method to build a DateTile (with tap to select date)
  static Widget buildDateTile(
    String label,
    DateTime? date,
    BuildContext context,
    bool someFlag, // Add this parameter to accept the 'true' value
    Function(BuildContext, DateTime?) selectDate,
  ) {
    return GestureDetector(
      onTap: () => selectDate(context, date),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              date != null
                  ? DateFormat('dd MMMM yyyy').format(date)
                  : 'Select Date',
              style: TextStyle(fontSize: 16),
            ),
            const Icon(Icons.calendar_today),
          ],
        ),
      ),
    );
  }

  // Method to build a time field with gesture and custom design
  static Widget buildTimeField(
    String label,
    TextEditingController controller,
    BuildContext context,
    Function(BuildContext) selectTime,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: controller,
        readOnly: true, // Only allow input via the time picker
        onTap: () => selectTime(context),
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.access_time),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0), // Adds padding inside the TextField
        ),
      ),
    );
  }

  static Widget buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    Color backgroundColor = const Color.fromARGB(255, 138, 172, 207),
    Color labelColor = Colors.black,
    Color textColor = Colors.black,
    double borderRadius = 30.0,
    EdgeInsets contentPadding = const EdgeInsets.all(12),
    double fontSize = 14.0,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      padding: const EdgeInsets.symmetric(vertical: 4), // Add some padding
      child: DropdownButtonHideUnderline(
        child: DropdownButton2(
          isExpanded: true,
          hint: Text(
            label,
            style: TextStyle(
              color: labelColor,
              fontSize: fontSize,
            ),
          ),
          value: value,
          onChanged: onChanged,
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: TextStyle(fontSize: fontSize, color: textColor),
              ),
            );
          }).toList(),
          buttonStyleData: ButtonStyleData(
            padding: contentPadding,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
          dropdownStyleData: DropdownStyleData(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              color: Colors.white, // Background color of the dropdown menu
            ),
          ),
          iconStyleData: IconStyleData(
            icon: Icon(Icons.arrow_drop_down, color: labelColor),
            iconSize: 24,
          ),
        ),
      ),
    );
  }
}
