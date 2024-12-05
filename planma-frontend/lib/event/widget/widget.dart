import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts

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
          labelStyle: GoogleFonts.openSans(
            fontSize: 14,
            color: Colors.grey[600],
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
      ),
    );
  }

  // Method to build a DateTile (with tap to select date)
  static Widget buildDateTile(
    String label,
    DateTime? date,
    BuildContext context,
    bool someFlag,
    Function(BuildContext, DateTime?) selectDate,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(30),
      ),
      child: ListTile(
        title: Text(
          '$label: ${date != null ? DateFormat('dd MMMM yyyy').format(date) : 'Select Date'}',
          style: GoogleFonts.openSans(
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        trailing: const Icon(Icons.calendar_today),
        onTap: () => selectDate(context, date),
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
        readOnly: true,
        onTap: () => selectTime(context),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.openSans(
            fontSize: 14,
            color: Colors.grey[600],
          ),
          suffixIcon: const Icon(Icons.access_time),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
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
    Color backgroundColor = const Color.fromARGB(255, 138, 172, 207),
    Color labelColor = Colors.black,
    Color textColor = Colors.black,
    double borderRadius = 30.0,
    EdgeInsets contentPadding = const EdgeInsets.all(16),
    double fontSize = 14.0,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2(
          isExpanded: true,
          hint: Text(
            label,
            style: GoogleFonts.openSans(
              fontSize: fontSize,
              color: labelColor,
            ),
          ),
          value: value,
          onChanged: onChanged,
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: GoogleFonts.openSans(
                  fontSize: fontSize,
                  color: textColor,
                ),
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
              color: Colors.white,
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

  static Widget dropwDownForAttendance({
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
    TextStyle? textStyle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(
          color: getColor(value!),
        ),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2(
          isExpanded: true,
          hint: Text(
            label,
            style:
                textStyle ?? TextStyle(color: labelColor, fontSize: fontSize),
          ),
          value: value,
          onChanged: onChanged,
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        color:
                            item == value ? getColor(item) : Color(0xFF173F70),
                      ),
                    ),
                  ),
                ],
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
              color: Colors.white,
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

  static Color getColor(String value) {
    switch (value) {
      case 'Did Not Attend':
        return Color(0xFFEF4738);
      case 'Excused':
        return Color(0xFF3654CC);
      case 'Attended':
        return Color(0xFF32C652);
      default:
        return Colors.grey; // Default for unselected
    }
  }
}
