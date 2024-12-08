import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:planma_app/authentication/log_in.dart';
import 'package:planma_app/Front%20&%20back%20end%20connections/auth_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:planma_app/user_preferences/sleep_wake.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  // Controllers for form fields
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // For toggling password visibility
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  // Global key for the form
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    // Dispose controllers when not in use
    firstNameController.dispose();
    lastNameController.dispose();
    userNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _signUp() async {
    if (_formKey.currentState!.validate()) {
      // Perform sign-up logic (e.g., API call)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Signing up...")),
      );

      final authService = AuthService();
      final response = await authService.signUp(
        firstName: firstNameController.text,
        lastName: lastNameController.text,
        username: userNameController.text,
        email: emailController.text,
        password: passwordController.text,
      );

      if (response != null && response["error"] == null) {
        // Sign-up successful, navigate to the login page
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account created successfully!")),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>
          SleepWakeSetupScreen(
            studentId: response["studentId"],
            usualSleepTime: '23:00',
            usualWakeTime: '07:00',
          )
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response?["error"] ?? "Unknown error")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shadowColor: Color(0xFFFFFFFF),
      ),
      backgroundColor: Color(0xFFFFFFFF),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Sign Up text below AppBar
                Text(
                  'Sign Up',
                  style: GoogleFonts.openSans(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF173F70),
                  ),
                ),
                const SizedBox(height: 20), // Spacing between title and form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: firstNameController,
                        decoration: InputDecoration(
                          labelStyle: GoogleFonts.openSans(),
                          labelText: 'First Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) => value!.isEmpty
                            ? 'Please enter your first name'
                            : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: lastNameController,
                        decoration: InputDecoration(
                          labelStyle: GoogleFonts.openSans(),
                          labelText: 'Last Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) => value!.isEmpty
                            ? 'Please enter your last name'
                            : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: userNameController,
                        decoration: InputDecoration(
                          labelStyle: GoogleFonts.openSans(),
                          labelText: 'Username',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) => value!.isEmpty
                            ? 'Please enter your username'
                            : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelStyle: GoogleFonts.openSans(),
                          labelText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? 'Please enter your email' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: passwordController,
                        obscureText: obscurePassword,
                        decoration: InputDecoration(
                          labelStyle: GoogleFonts.openSans(),
                          labelText: 'Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () {
                              setState(() {
                                obscurePassword = !obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) => value!.isEmpty
                            ? 'Please enter your password'
                            : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: confirmPasswordController,
                        obscureText: obscureConfirmPassword,
                        decoration: InputDecoration(
                          labelStyle: GoogleFonts.openSans(),
                          labelText: 'Confirm Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(obscureConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () {
                              setState(() {
                                obscureConfirmPassword =
                                    !obscureConfirmPassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 50),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _signUp();
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => LogIn()),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 100, vertical: 15),
                          backgroundColor: const Color(0xFF173F70),
                        ),
                        child: Text(
                          'Create Account',
                          style: GoogleFonts.openSans(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      RichText(
                        text: TextSpan(
                          text: 'Already have an account? ',
                          style: GoogleFonts.openSans(
                            color: Color(0xFF173F70),
                          ),
                          children: [
                            TextSpan(
                              text: 'Login',
                              style: GoogleFonts.openSans(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF173F70),
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => LogIn()),
                                  );
                                },
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
