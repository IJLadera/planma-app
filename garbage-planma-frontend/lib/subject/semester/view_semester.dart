import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:planma_app/activities/widget/search_bar.dart';
import 'package:provider/provider.dart';
import 'package:planma_app/Providers/semester_provider.dart';
import 'package:planma_app/subject/semester/add_semester.dart';
import 'package:planma_app/subject/semester/semester_card.dart';

class SemesterScreen extends StatefulWidget {
  const SemesterScreen({super.key});

  @override
  State<SemesterScreen> createState() => _SemesterScreenState();
}

class _SemesterScreenState extends State<SemesterScreen> {
  @override
  void initState() {
    super.initState();
    final semesterProvider =
        Provider.of<SemesterProvider>(context, listen: false);
    semesterProvider.fetchSemesters();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SemesterProvider>(
    builder: (context, semesterProvider, child) {
  return Scaffold(
    appBar: AppBar(
      title: Text(
        'Semesters',
        style: GoogleFonts.openSans(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF173F70),
        ),
      ),
      backgroundColor: Colors.white,
      centerTitle: true,
      elevation: 0,
    ),
    body: semesterProvider.semesters.isEmpty
        ? Center(
            child: Text(
              'No semesters found',
              style: GoogleFonts.openSans(fontSize: 16, color: Colors.black),
            ),
          )
        : Column(
            children: [
              Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8.0),
              child: CustomSearchBar(),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: semesterProvider.semesters.length,
                  itemBuilder: (context, index) {
                    final semester = semesterProvider.semesters[index];
                    return SemesterCard(semester: semester);
                  },
                ),
              ),
            ],
          ),
    floatingActionButton: FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const AddSemesterScreen()),
        );
      },
      backgroundColor: const Color(0xFF173F70),
      shape: const CircleBorder(),
      child: const Icon(Icons.add, color: Colors.white),
    ),
  );
});
  }
}
