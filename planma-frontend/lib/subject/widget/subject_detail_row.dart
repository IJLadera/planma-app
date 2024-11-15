// subject_detail_row.dart
import 'package:flutter/material.dart';

class SubjectDetailRow extends StatelessWidget {
  final String title;
  final String detail;

  const SubjectDetailRow({
    Key? key,
    required this.title,
    required this.detail,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              title,
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.grey[800]),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              detail,
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
