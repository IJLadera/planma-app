import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
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
        padding: const EdgeInsets.all(16),
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
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF173F70),
        ),
      ),
    );
  }

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
        readOnly: true,
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

  static Widget buildDropdownField<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required Function(T?) onChanged,
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
          items: items,
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
}
