import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts

class CustomSearchBar extends StatelessWidget {
  const CustomSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search',
          hintStyle: GoogleFonts.openSans(
            // Apply Open Sans to the hint text
            fontSize: 16,
            color: Colors.grey,
          ),
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(
                color: Colors.black,
                width: 1,
              )),
        ),
        style: GoogleFonts.openSans(
          // Apply Open Sans to the input text
          fontSize: 16,
          color: Colors.black,
        ),
      ),
    );
  }
}
