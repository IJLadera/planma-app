import 'package:flutter/material.dart';

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
            style: TextStyle(fontSize: 16.0, color: Colors.black),
          ),
          Text(
            time.format(context),
            style: TextStyle(fontSize: 16.0, color: Colors.black),
          ),
        ],
      ),
    ),
  );
}
