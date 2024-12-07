import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget buildTimePickerField({
  required BuildContext context,
  required String label,
  required TimeOfDay time,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style:
                GoogleFonts.openSans(fontSize: 16.0, color: Color(0xFF173F70)),
          ),
          Text(
            time.format(context),
            style:
                GoogleFonts.openSans(fontSize: 16.0, color: Color(0xFF173F70)),
          ),
        ],
      ),
    ),
  );
}
