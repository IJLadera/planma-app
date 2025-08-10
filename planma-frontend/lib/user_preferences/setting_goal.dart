// import 'package:flutter/material.dart';
// import 'package:planma_app/core/dashboard.dart';
// import 'package:planma_app/user_preferences/widget/goal_option.dart';
// import 'package:google_fonts/google_fonts.dart';

// class GoalSelectionScreen extends StatelessWidget {
//   const GoalSelectionScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 50),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Center(
//                 child: Text(
//                   "Let’s make things happen!",
//                   style: GoogleFonts.openSans(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                     color: Color(0xFF173F70),
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//               const SizedBox(height: 20),

//               // Subheading Text
//               Center(
//                 child: Text(
//                   "What’s the first goal you’d like to work toward?",
//                   style: GoogleFonts.openSans(
//                     fontSize: 16,
//                     color: Color(0xFF173F70),
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//               const SizedBox(height: 20), // Adjusted to reduce space
//               Expanded(
//                 child: ListView(
//                   shrinkWrap: true, // Allows ListView to occupy minimal height
//                   children: [
//                     GoalOptionTile(title: "Study for the Whole Semester"),
//                     GoalOptionTile(title: "Exercise"),
//                     GoalOptionTile(title: "Practice a Skill"),
//                     GoalOptionTile(title: "Train for an Event"),
//                   ],
//                 ),
//               ),
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.push(context, MaterialPageRoute(builder: (context) => Dashboard(), ));
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Color(0xFF173F70),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8.0),
//                   ),
//                   minimumSize: const Size(double.infinity, 50),
//                 ),
//                 child: Text(
//                   "Next",
//                   style: GoogleFonts.openSans(fontSize: 18, color: Colors.white),
//                 ),
//               ),
//               const SizedBox(height: 20),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
