import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class CustomWidget {
  /// Builds a time picker field widget
  static Widget buildTimePickerField({
    required BuildContext context,
    required String label,
    required TimeOfDay time,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.openSans(
                fontSize: 16.0,
                color: const Color(0xFF173F70),
              ),
            ),
            Text(
              time.format(context),
              style: GoogleFonts.openSans(
                fontSize: 16.0,
                color: const Color(0xFF173F70),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget buildDateTile(
    String label,
    TextEditingController controller,
    BuildContext context,
    bool someFlag,
    Function(BuildContext, TextEditingController) selectDate,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: () => selectDate(context, controller), // Trigger the date picker
        child: AbsorbPointer(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(30),
            ),
            child: ListTile(
              title: TextFormField(
                controller: controller,
                readOnly: true, // To prevent manual input
                style: GoogleFonts.openSans(
                  fontSize: 14, // Make sure the font size is set here
                  color: Colors.black, // Ensure text color is applied correctly
                ),
                decoration: InputDecoration(
                  labelText: label,
                  labelStyle: GoogleFonts.openSans(
                    fontSize: 14, // Ensure the label style matches
                    color: Colors.black, // Label text color
                  ),
                  suffixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 5),
            ),
          ),
        ),
      ),
    );
  }

  static Widget buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    Color backgroundColor = const Color(0xFFF5F5F5),
    Color labelColor = Colors.black,
    Color textColor = Colors.black,
    double borderRadius = 30.0,
    EdgeInsets contentPadding = const EdgeInsets.all(100),
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
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: textStyle ??
                    GoogleFonts.openSans(fontSize: fontSize, color: textColor),
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

  static Widget buildYearPickerButton({
    required BuildContext context,
    required String hint,
    required bool isStartYear,
    required String? selectedStartYear,
    required String? selectedEndYear,
    required Function(BuildContext, bool)
        onTap, // Keeps the onTap function similar to old code
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () =>
            onTap(context, isStartYear), // Triggers the same action as before
        child: buildContainer(
          Text(
            isStartYear
                ? selectedStartYear ?? hint
                : selectedEndYear ?? hint, // Displays the selected year or hint
            style: GoogleFonts.openSans(fontSize: 14),
          ),
        ),
      ),
    );
  }

  static Widget buildContainer(Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          child,
          const Spacer(),
          const Icon(Icons.calendar_today),
        ],
      ),
    );
  }
}
