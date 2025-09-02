import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomWidgets {
  // Method to build a TextField with custom style
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
              style: GoogleFonts.openSans(fontSize: 14),
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
    Function(BuildContext) selectTime, {
    TextStyle? textStyle,
  }) {
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
          labelStyle: textStyle ?? GoogleFonts.openSans(fontSize: 14),
          suffixIcon: const Icon(Icons.access_time),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  static Widget buildTitle(String title) {
    return Container(
      margin: const EdgeInsets.only(
          left: 16.0,
          top: 8.0,
          right: 16.0), // Adjust the margin values as needed
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
}
