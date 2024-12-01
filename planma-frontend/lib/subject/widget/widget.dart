import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

import 'package:google_fonts/google_fonts.dart'; // Ensure this import is at the top

class DayButton extends StatelessWidget {
  final String day;
  final bool isSelected;
  final VoidCallback onTap;

  const DayButton({
    super.key,
    required this.day,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 16,
        backgroundColor: isSelected ? Colors.blue : Colors.grey[200],
        child: Text(
          day,
          style: GoogleFonts.openSans(
            fontSize: 16,
            color: isSelected
                ? Colors.white
                : Colors.black, // You can adjust color based on selection
          ),
        ),
      ),
    );
  }
}

class CustomWidgets {
  static Widget buildTextField(
      TextEditingController controller, String labelText,
      {TextStyle? style}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: controller,
        style: style ??
            const TextStyle(), // Apply the passed style or default style
        decoration: InputDecoration(
          labelText: labelText,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  static Widget buildDateTile(String label, DateTime? date,
      BuildContext context, Function(BuildContext, DateTime?) selectDate,
      {TextStyle? textStyle} // Optional text style parameter
      ) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(30),
      ),
      child: ListTile(
        title: Text(
          '$label: ${date != null ? DateFormat('dd MMMM yyyy').format(date) : 'Select Date'}',
          style: textStyle ??
              const TextStyle(
                  fontSize: 16), // Apply custom style or default style
        ),
        trailing: const Icon(Icons.calendar_today),
        onTap: () => selectDate(context, date),
      ),
    );
  }

  // Method to build a time field with gesture and custom design
  static Widget buildTimeField(String label, TextEditingController controller,
      BuildContext context, Function(BuildContext) selectTime,
      {TextStyle? textStyle} // Optional text style parameter
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
          contentPadding: const EdgeInsets.all(16),
          labelStyle: textStyle ??
              const TextStyle(
                  fontSize: 16), // Apply custom style or default style
        ),
      ),
    );
  }

  // Method to build a dropdown field with custom design
  static Widget buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    Color backgroundColor = const Color(0xFFF5F5F5),
    Color labelColor = Colors.black,
    Color textColor = Colors.black,
    double borderRadius = 30.0,
    EdgeInsets contentPadding = const EdgeInsets.all(16),
    double fontSize = 14.0,
    TextStyle? textStyle, // Optional text style parameter
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
            style: textStyle ??
                TextStyle(
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
                style: textStyle ??
                    TextStyle(fontSize: fontSize, color: textColor),
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
