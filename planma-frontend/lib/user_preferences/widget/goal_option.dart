import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GoalOptionTile extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const GoalOptionTile({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF173F70).withOpacity(0.1)
              : Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFF173F70) : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          children: [
            Checkbox(
              value: isSelected,
              onChanged: (_) => onTap(),
              activeColor: const Color(0xFF173F70),
            ),
            const SizedBox(width: 8.0),
            Text(
              title,
              style: GoogleFonts.openSans(
                fontSize: 16,
                color: isSelected ? const Color(0xFF173F70) : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
