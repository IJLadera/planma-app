import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
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
          labelStyle: GoogleFonts.openSans(),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        ),
      ),
    );
  }

  // Method to build a DateTile (with tap to select date)
  static Widget buildDateTile(
    String label,
    DateTime? date,
    BuildContext context,
    bool isScheduledDate,
    Function selectDate,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(30),
      ),
      child: ListTile(
        title: Text(
          '$label: ${date != null ? DateFormat('dd MMMM yyyy').format(date) : 'Select Date'}',
          style: GoogleFonts.openSans(),
        ),
        trailing: const Icon(Icons.calendar_today),
        onTap: () => selectDate(context, isScheduledDate),
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

  // Method to build a dropdown field with custom styling
  static Widget buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    Color backgroundColor = const Color(0xFFF5F5F5),
    Color labelColor = Colors.black,
    Color textColor = Colors.black,
    double borderRadius = 30.0,
    EdgeInsets contentPadding =
        const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
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

  static Widget buildPicker({
    required int max,
    required int selectedValue,
    required Function(int) onSelectedItemChanged,
    double height = 100,
    double width = 60,
    double fontSize = 16,
  }) {
    return SizedBox(
      height: height,
      width: width,
      child: CupertinoPicker(
        scrollController: FixedExtentScrollController(
          initialItem: selectedValue,
        ),
        itemExtent: 40,
        onSelectedItemChanged: onSelectedItemChanged,
        children: List<Widget>.generate(max + 1, (int index) {
          return Center(
            child: Text(
              index
                  .toString()
                  .padLeft(3, '0'), // Adjust padding for large numbers
              style: TextStyle(fontSize: fontSize),
            ),
          );
        }),
      ),
    );
  }

  static Widget buildScheduleDatePicker({
    required BuildContext context,
    required String displayText, // The initial or current duration to display
    required Future<void> Function()
        onPickerTap, // Callback for showing the picker
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onPickerTap, // Trigger the picker when tapped
          child: Container(
            padding: const EdgeInsets.symmetric(
                vertical: 12, horizontal: 16), // Outer padding
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5), // Light gray background
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  // Adds inner padding for the Text widget
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Text(
                    displayText,
                    style: GoogleFonts.openSans(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                ),
                const Icon(
                  Icons.timer_outlined, // Timer icon for duration
                  color: Color(0xFF173F70),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
