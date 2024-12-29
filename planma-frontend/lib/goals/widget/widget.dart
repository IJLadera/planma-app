import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class CustomWidgets {
  static Widget buildTitle(String title) {
    return Container(
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.only(left: 16.0, top: 8.0, right: 16.0),
      child: Text(
        title,
        style: GoogleFonts.openSans(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF173F70),
        ),
      ),
    );
  }

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
          labelStyle: GoogleFonts.openSans(fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
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
    double fontSize = 14.0, required TextStyle textStyle,
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
            padding: const EdgeInsets.all(16), // Outer padding
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
                      horizontal: 16.0, vertical: 5.0),
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

  static String formatDurationText(Duration duration) {
    int hours = duration.inHours;
    int minutes = duration.inMinutes % 60;

    // Display only "30 mins" if 30 minutes is selected
    if (hours == 0 && minutes == 30) {
      return '$minutes mins';
    }

    // Display "1 hour" instead of "1 hours"
    if (hours == 1 && minutes == 0) {
      return '$hours hour';
    }

    // General case for other durations
    if (hours > 0 && minutes > 0) {
      return '$hours hrs and $minutes mins';
    } else if (hours > 0) {
      return '$hours hrs';
    } else {
      return '$minutes mins';
    }
  }

  static Future<void> showDurationPicker(
    BuildContext context,
    Duration initialDuration,
    Function(Duration) onDurationSelected,
  ) async {
    // Initial selected hours and minutes from the target duration
    int selectedHours = initialDuration.inHours;
    int selectedMinutes = initialDuration.inMinutes % 60;

    // Show duration picker dialog
    final newDuration = await showDialog<Duration>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              title: Text(
                'Set Target Duration',
                style: GoogleFonts.openSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF173F70),
                ),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              content: SizedBox(
                width: 200,
                height: 200,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Hours Picker
                        buildPicker(
                          max: 99, // Maximum hours limit
                          selectedValue: selectedHours,
                          onSelectedItemChanged: (value) {
                            setModalState(() {
                              selectedHours = value;
                            });
                          },
                        ),
                        const Text(':',
                            style:
                                TextStyle(fontSize: 18, color: Colors.black)),
                        // Minutes Picker (0 or 30)
                        buildPicker(
                          max: 1, // Restrict to two values: 0 or 30
                          selectedValue:
                              selectedMinutes ~/ 30, // Map 0 -> 0, 30 -> 1
                          onSelectedItemChanged: (value) {
                            setModalState(() {
                              selectedMinutes =
                                  value * 30; // Map back to 0 or 30
                            });
                          },
                          // List of minutes options (00 or 30)
                          children: List<Widget>.generate(2, (index) {
                            return Center(
                              child: Text(index == 0 ? '00' : '30'),
                            );
                          }),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              actions: [
                SizedBox(height: 30),
                // Cancel button
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style:
                        GoogleFonts.openSans(fontSize: 16, color: Colors.black),
                  ),
                ),
                // Set Duration button
                ElevatedButton(
                  onPressed: (selectedHours == 0 && selectedMinutes == 0)
                      ? null
                      : () {
                          Navigator.pop(
                            context,
                            Duration(
                                hours: selectedHours, minutes: selectedMinutes),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 12.0),
                    backgroundColor: Color(0xFF173F70),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Set Duration',
                    style: GoogleFonts.openSans(
                        fontSize: 16, color: Color(0xFFFFFFFF)),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    // Update the target duration if a new value is selected
    if (newDuration != null) {
      onDurationSelected(newDuration);
    }
  }

  static Widget buildPicker({
    required int max,
    required int selectedValue,
    required Function(int) onSelectedItemChanged,
    List<Widget>? children, // Optional children parameter
  }) {
    return SizedBox(
      height: 200,
      width: 70,
      child: CupertinoPicker(
        scrollController:
            FixedExtentScrollController(initialItem: selectedValue),
        itemExtent: 50,
        onSelectedItemChanged: onSelectedItemChanged,
        children: children ??
            List<Widget>.generate(max + 1, (int index) {
              // This will hide numbers outside the desired range for hours
              if (index > max) return SizedBox.shrink(); // Hide numbers
              return Center(
                child: Text(index.toString().padLeft(2, '0'),
                    style: const TextStyle(fontSize: 14)),
              );
            }),
      ),
    );
  }
}
