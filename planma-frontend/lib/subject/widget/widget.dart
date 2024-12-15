import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:google_fonts/google_fonts.dart';

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
        radius: 20,
        backgroundColor: isSelected ? Color(0xFF173F70) : Colors.grey[200],
        child: Text(
          day,
          style: GoogleFonts.openSans(
            fontSize: 14,
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}

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
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: controller,
        style: style ?? GoogleFonts.openSans(fontSize: 14),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: GoogleFonts.openSans(fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
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
          style: GoogleFonts.openSans(
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
          iconStyleData: IconStyleData(
            icon: Icon(Icons.arrow_drop_down,
                color: labelColor), // Custom arrow icon
            iconSize: 24, // Adjust the arrow size
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
        return Color(0xFFF5F5F5);
    }
  }
}
