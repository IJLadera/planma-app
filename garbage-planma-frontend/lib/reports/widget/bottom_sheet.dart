import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BottomSheetWidget extends StatelessWidget {
  final Function(String) onCategorySelected;
  final String initialSelection;

  const BottomSheetWidget({
    super.key,
    required this.onCategorySelected,
    required this.initialSelection,
  });

  // Static method to show the BottomSheet
  static void show(BuildContext context,
      {required Function(String) onCategorySelected,
      required String initialSelection}) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return BottomSheetWidget(
            onCategorySelected: onCategorySelected,
            initialSelection: initialSelection);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Text(
                "Categories",
                style: GoogleFonts.openSans(
                  fontSize: 20, 
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF173F70),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildRadioTile(
              title: "Tasks",
              value: "Tasks",
              onChanged: (value) {
                onCategorySelected(
                    value!); // Pass the selected category to the callback
                Navigator.pop(context); // Close the bottom sheet
              },
            ),
            _buildRadioTile(
              title: "Events",
              value: "Events",
              onChanged: (value) {
                onCategorySelected(value!);
                Navigator.pop(context);
              },
            ),
            _buildRadioTile(
              title: "Class Schedules",
              value: "Class Schedules",
              onChanged: (value) {
                onCategorySelected(value!);
                Navigator.pop(context);
              },
            ),
            _buildRadioTile(
              title: "Activities",
              value: "Activities",
              onChanged: (value) {
                onCategorySelected(value!);
                Navigator.pop(context);
              },
            ),
            _buildRadioTile(
              title: "Goals",
              value: "Goals",
              onChanged: (value) {
                onCategorySelected(value!);
                Navigator.pop(context);
              },
            ),
            _buildRadioTile(
              title: "Sleep",
              value: "Sleep",
              onChanged: (value) {
                onCategorySelected(value!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioTile({
    required String title,
    required String value,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      children: [
        RadioListTile<String>(
          contentPadding: EdgeInsets.zero,
          // visualDensity: VisualDensity(horizontal: -4, vertical: -4), // Compress further
          title: Text(
            title,
            style: GoogleFonts.openSans(
              fontSize: 14,
              color: Color(0xFF173F70),
            ),
          ),
          value: value,
          groupValue: initialSelection,
          onChanged: onChanged,
          controlAffinity: ListTileControlAffinity.trailing,
          activeColor: Color(0xFF1D4E89),
        ),
        if (title != "Sleep") // No divider below the last option
          const Divider(height: 0.5, thickness: 1,),
      ],
    );
  }
}
