import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:planma_app/subject/semester/search_bar.dart';
import 'package:planma_app/subject/semester/semester_card.dart';
import 'package:planma_app/subject/semester/add_semester.dart';

class SemesterScreen extends StatefulWidget {
  const SemesterScreen({Key? key}) : super(key: key);

  @override
  _SemesterScreenState createState() => _SemesterScreenState();
}

class _SemesterScreenState extends State<SemesterScreen> {
  List<Map<String, String>> semesters = [
    {
      'title': 'S.Y. 2024 - 2025',
      'dateRange': '05 Sept 2024 - 21 Dec 2024',
      'year': '4th Year',
      'semester': '1st Semester',
    },
    {
      'title': 'S.Y. 2024 - 2025',
      'dateRange': '05 Sept 2024 - 21 Dec 2024',
      'year': '4th Year',
      'semester': '2nd Semester',
    },
  ];

  void _editSemester(int index) {
    print("Edit semester: ${semesters[index]['title']}");
  }

  void _deleteSemester(int index) {
    setState(() {
      semesters.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Semesters',
          style: GoogleFonts.openSans(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF173F70),
          ),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8.0),
            child: CustomSearchBar(),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: semesters.length,
              itemBuilder: (context, index) {
                return SemesterCard(
                  title: semesters[index]['title']!,
                  dateRange: semesters[index]['dateRange']!,
                  yearLevel: semesters[index]['year']!,
                  semester: semesters[index]['semester']!,
                  onEdit: () => _editSemester(index),
                  onDelete: () => _deleteSemester(index),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddSemesterScreen()),
          );
        },
        backgroundColor: const Color(0xFF173F70),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
