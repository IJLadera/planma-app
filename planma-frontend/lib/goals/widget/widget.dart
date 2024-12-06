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
    TimeOfDay? time,
    BuildContext context,
    bool isStartTime,
    Function selectTime,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(30),
      ),
      child: GestureDetector(
        onTap: () => selectTime(context, isStartTime),
        child: AbsorbPointer(
          child: TextFormField(
            decoration: InputDecoration(
              labelText: label,
              labelStyle: GoogleFonts.openSans(),
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

  // Method to build a session tile with dynamic data
  static Widget buildSessionTile(Map<String, dynamic> session) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            session['name'] ?? 'Session Name',
            style: GoogleFonts.openSans(),
          ),
          const SizedBox(height: 4),
          Text(
            'Date: ${session['date'] ?? 'Not Set'}',
            style: GoogleFonts.openSans(),
          ),
          Text(
            'Time Period: ${session['timePeriod'] ?? 'Not Set'}',
            style: GoogleFonts.openSans(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // Method to build a detail tile with title and value
  static Widget buildDetailTile(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.openSans(
              fontSize: 16,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: GoogleFonts.openSans(
                fontSize: 16,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildPicker({
    required int max,
    required int selectedValue,
    required Function(int) onSelectedItemChanged,
    double height = 100,
    double width = 40,
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
        children: List<Widget>.generate(max, (int index) {
          return Center(
            child: Text(
              index.toString().padLeft(2, '0'), // Zero-padding for consistency
              style: TextStyle(fontSize: fontSize),
            ),
          );
        }),
      ),
    );
  }
}
