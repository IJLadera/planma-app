import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GoalOptionTile extends StatefulWidget {
  final String title;

  const GoalOptionTile({super.key, required this.title});

  @override
  _GoalOptionTileState createState() => _GoalOptionTileState();
}

class _GoalOptionTileState extends State<GoalOptionTile> {
  bool _isSelected = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isSelected = !_isSelected;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color:
              _isSelected ? Color(0xFF173F70).withOpacity(0.1) : Colors.white,
          border: Border.all(
            color: _isSelected ? Color(0xFF173F70) : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          children: [
            Checkbox(
              value: _isSelected,
              onChanged: (value) {
                setState(() {
                  _isSelected = value!;
                });
              },
              activeColor: Color(0xFF173F70),
            ),
            const SizedBox(width: 8.0),
            Text(
              widget.title,
              style: GoogleFonts.openSans(
                fontSize: 16,
                color: _isSelected ? Color(0xFF173F70) : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
