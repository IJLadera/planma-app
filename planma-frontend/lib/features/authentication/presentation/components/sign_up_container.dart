import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:planma_app/features/authentication/presentation/pages/sign_up_page.dart';
import 'package:flutter/gestures.dart';

class SignUpContainer extends StatelessWidget {
  const SignUpContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 70),
        child: RichText(
          text: TextSpan(
            text: "Don't have an account? ",
            style: GoogleFonts.openSans(
              color: Color(0xFF173F70),
              fontSize: 16,
            ),
            children: [
              TextSpan(
                text: 'Sign Up',
                style: GoogleFonts.openSans(
                  color: const Color(0xFF173F70),
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SignUpPage(),
                      ),
                    );
                  },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
