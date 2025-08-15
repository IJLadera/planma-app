import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts

class CustomWidgets {
  static Widget buildTitle(String title) {
    return Container(
      margin: const EdgeInsets.only(left: 16.0, top: 8.0, right: 16.0),
      alignment: Alignment.centerLeft, // Ensures the text starts from the left
      child: Text(
        title,
        style: GoogleFonts.openSans(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xFF173F70),
        ),
      ),
    );
  }

  static Widget buildTextField(
    TextEditingController controller,
    String labelText, {
    TextStyle? style,
    TextStyle? labelStyle,
    Color backgroundColor = const Color(0xFFF5F5F5),
    Color readOnlyBackgroundColor = const Color(0xFFE0E0E0),
    double borderRadius = 30.0,
    EdgeInsetsGeometry contentPadding = const EdgeInsets.all(16),
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        color: readOnly ? readOnlyBackgroundColor : backgroundColor,
      ),
      child: TextField(
        controller: controller,
        style: style ??
            GoogleFonts.openSans(
              fontSize: 14,
              color: readOnly ? Colors.grey : Colors.black,
            ),
        readOnly: readOnly,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: labelStyle ??
              GoogleFonts.openSans(
                fontSize: 14,
                color: readOnly ? Colors.grey : Colors.black,
              ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide.none, // still no visible border lines
          ),
          contentPadding: contentPadding,
          filled: true,
          fillColor: Colors.transparent, // already handled by Container
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
        padding: const EdgeInsets.all(18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
                date != null
                    ? DateFormat('dd MMMM yyyy').format(date)
                    : 'Select Date',
                style: GoogleFonts.openSans(fontSize: 14)),
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
        readOnly: true,
        onTap: () => selectTime(context),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.openSans(
            fontSize: 14,
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
    Color backgroundColor = const Color(0xFFF5F5F5),
    Color labelColor = Colors.black,
    Color textColor = Colors.black,
    double borderRadius = 30.0,
    EdgeInsets contentPadding = const EdgeInsets.all(12),
    double fontSize = 14.0,
    TextStyle? textStyle,
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
            style: textStyle ??
                GoogleFonts.openSans(color: labelColor, fontSize: fontSize),
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
    Color labelColor = Colors.red,
    Color textColor = const Color(0xFF173F70),
    double borderRadius = 70.0,
    double fontSize = 14.0,
    TextStyle? textStyle,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: 20.0, vertical: 10.0), // Margin around the dropdown
      decoration: BoxDecoration(
        color: backgroundColor, // Light background color
        border: Border.all(
          color: value != null ? getColor(value) : Colors.blue, // Border color
          width: 2.0, // Border width
        ),
        borderRadius: BorderRadius.circular(borderRadius), // Rounded corners
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          isExpanded: true,
          hint: Text(
            label,
            style: textStyle ??
                GoogleFonts.openSans(
                  color: labelColor,
                  fontSize: fontSize,
                ),
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
                      style: GoogleFonts.openSans(
                        color: item == value
                            ? getColor(item) // Highlight selected item
                            : const Color(0xFF173F70), // Default text color
                        fontWeight: FontWeight.w500, // Medium weight for items
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          selectedItemBuilder: (context) {
            return items.map((item) {
              return Row(
                children: [
                  Icon(
                    Icons.label,
                    size: 18,
                    color: getColor(item),
                  ),
                  SizedBox(width: 5),
                  Text(
                    item,
                    style: GoogleFonts.openSans(
                      color: getColor(item),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            }).toList();
          },
          style: GoogleFonts.openSans(
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
          iconStyleData: IconStyleData(
            icon: Icon(Icons.arrow_drop_down,
                color: value != null ? getColor(value) : labelColor), // Custom arrow icon
            iconSize: 24, // Adjust the arrow size
          ),
          buttonStyleData: ButtonStyleData(
            height: 40,
          ),
          dropdownStyleData: DropdownStyleData(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                  borderRadius), // Rounded corners for dropdown
              color: Colors.white, // Background color for the dropdown
            ),
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
